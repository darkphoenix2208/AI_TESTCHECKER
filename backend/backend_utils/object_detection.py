"""
YOLO-based object detection utilities for detecting forbidden objects.
Uses Ultralytics YOLO directly (avoids torch.hub trust prompt issues).
"""
import os
from config import Config

# Global YOLO model instance
_yolo_model = None
_yolo_available = False

def load_yolo_model():
    """
    Load YOLO model using Ultralytics directly.
    Uses singleton pattern to load model only once.
    
    Returns:
        tuple: (model, is_available) - Model instance and availability flag
    """
    global _yolo_model, _yolo_available
    
    if _yolo_model is not None:
        return _yolo_model, _yolo_available
    
    print("Loading YOLO model for object detection...")
    
    try:
        from ultralytics import YOLO
        
        model_path = Config.YOLO_MODEL_PATH
        
        if os.path.exists(model_path):
            _yolo_model = YOLO(model_path)
            print(f"✓ Loaded custom YOLO model from {model_path}")
        else:
            # Use a small pretrained YOLOv5n model (auto-downloads if not cached)
            _yolo_model = YOLO('yolov5nu.pt')
            print("✓ Loaded pretrained YOLOv5n model via Ultralytics")
        
        _yolo_available = True
        print("✓ YOLO model loaded successfully for cell phone/laptop detection")
        
    except Exception as e:
        print(f"✗ Failed to load YOLO model: {e}")
        print("  Cell phone/laptop detection will not be available")
        _yolo_available = False
        _yolo_model = None
    
    return _yolo_model, _yolo_available


def detect_forbidden_objects(image_rgb):
    """
    Detect forbidden objects (cell phones, laptops, books) in an image.
    
    Args:
        image_rgb: RGB image array (numpy array)
    
    Returns:
        dict: Detection results with status and detected objects
    """
    model, available = load_yolo_model()
    
    if not available or model is None:
        return {
            'status': 'error',
            'message': 'Object detection not available'
        }
    
    try:
        # Run YOLO detection
        results = model(image_rgb, verbose=False)
        
        # Define forbidden objects (COCO dataset class names)
        forbidden_class_names = {'cell phone', 'laptop', 'book'}
        
        detected_forbidden = []
        all_detections = []
        
        for result in results:
            boxes = result.boxes
            if boxes is None:
                continue
            for box in boxes:
                class_id = int(box.cls[0])
                confidence = float(box.conf[0])
                class_name = model.names[class_id]
                
                if confidence > 0.3:
                    all_detections.append({
                        'name': class_name,
                        'confidence': confidence
                    })
                
                if class_name in forbidden_class_names and confidence > 0.4:
                    detected_forbidden.append({
                        'name': class_name,
                        'confidence': confidence
                    })
                    print(f"⚠️  FORBIDDEN OBJECT DETECTED: {class_name} (confidence: {confidence:.2f})")
        
        if detected_forbidden:
            return {
                'status': 'forbidden_object',
                'objects': [d['name'] for d in detected_forbidden],
                'details': detected_forbidden,
                'all_detections': all_detections
            }
        else:
            return {
                'status': 'clear',
                'all_detections': all_detections
            }
    
    except Exception as e:
        print(f"Object detection error: {e}")
        return {
            'status': 'error',
            'message': f'Detection failed: {str(e)}'
        }


def is_yolo_available():
    """Check if YOLO model is available"""
    _, available = load_yolo_model()
    return available
