# 🕵️‍♂️ SecureExam AI

A modern, AI-powered online exam proctoring system with real-time object detection, head pose tracking, audio anomaly detection, MongoDB integration, and comprehensive testing.

---

## 📋 Table of Contents

- [🚀 Features](#-features)
- [🛠 Tech Stack](#-tech-stack)
- [⚙ Installation](#-installation)
- [🔧 Configuration](#-configuration)
- [🧪 Testing](#-testing)
- [📁 Project Structure](#-project-structure)
- [📚 Usage Guide](#-usage-guide)
- [ Authentication](#-authentication)
- [📄 License](#-license)
- [ Documentation](#-documentation)

---

## 🚀 Features

### Student Features
- 👤 **User Authentication** - Roll number-based student login
- 📝 **Online Exam Interface** - MCQs with timer and auto-submit
- 🖥 **Fullscreen Enforcement** - Auto-submit on fullscreen exit
- 🎥 **Webcam Proctoring** - Face registration and live verification
- 🔍 **Head Pose Tracking** - Detects looking away (left/right/up/down)
- 🤳 **Object Detection** - Detects phones, laptops, and triggers alerts
- 🎤 **Audio Monitoring** - Detects speech and suspicious sounds
- 🔒 **Keyboard Restrictions** - Limits keys to prevent cheating

### Teacher/Proctor Features
- 👨‍🏫 **Secure Teacher Login** - MongoDB-based authentication
- 📊 **Real-time Dashboard** - Live monitoring of all exam sessions
- 📈 **Analytics & Charts** - Visual representation of alerts and statistics
- ⚠️ **Alert Management** - View and filter all cheating alerts
- 👥 **Student Monitoring** - Track individual student behavior

### System Features
- 🧪 **Comprehensive Testing** - 20+ backend tests, 19+ frontend tests
- 🗄️ **MongoDB Integration** - Scalable database for students, teachers, and alerts
- 🛡 **Security** - Protected routes, session management, teacher authentication
- 📱 **Responsive Design** - Works on various screen sizes
- 📝 **Detailed Logging** - All alerts stored with timestamps and metadata

---

## 🛠 Tech Stack

### Frontend
- **Framework:** React 19.1.0
- **Routing:** React Router DOM 7.6.3
- **UI:** Bootstrap 5.3.7
- **Webcam:** React Webcam 7.2.0
- **Charts:** Recharts 3.1.0
- **Testing:** Jest, React Testing Library

### Backend
- **Framework:** Flask 3.1.1
- **CORS:** Flask-CORS 6.0.1
- **Computer Vision:** OpenCV 4.8.1.78, MediaPipe
- **Object Detection:** Ultralytics YOLOv5
- **Database:** MongoDB Atlas (PyMongo 4.6.1)
- **Testing:** pytest 7.4.3, pytest-flask 1.3.0

### AI/ML Models
- **YOLOv5n** - Object detection (phones, laptops)
- **MediaPipe Face Mesh** - Head pose estimation
- **MediaPipe Face Detection** - Face registration/verification

---

## ⚙ Installation

### Prerequisites
- Python 3.11+
- Node.js 18+
- MongoDB Atlas account (or local MongoDB)

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/SecureExam-AI.git
cd SecureExam-AI
```

### 2. Backend Setup
```bash
cd backend

# Create virtual environment
python -m venv ../.venv

# Activate virtual environment
# On Windows:
..\.venv\Scripts\activate
# On Mac/Linux:
source ../.venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### 3. Frontend Setup
```bash
cd frontend

# Install dependencies
npm install
```

### 4. Configure MongoDB
Update the MongoDB URI in `backend/app.py`:
```python
MONGO_URI = "your_mongodb_connection_string"
```

Or use environment variables (recommended for production).

---

## 🔧 Configuration

### Backend Configuration
- **MongoDB URI:** Update in `backend/app.py` line 15
- **Port:** Default 5000 (configurable in `app.py`)
- **YOLOv5 Model:** Auto-downloaded on first run (~5.3MB)
- **CORS:** Configured for localhost:3000 (update for production)

### Frontend Configuration
- **API URL:** Default `http://localhost:5000` (update in components for production)
- **Port:** Default 3000 (configurable in package.json)

---

## 🧪 Testing

### Backend Testing

Run all backend tests:
```bash
cd testing/backend
pytest
```

Run with coverage:
```bash
pytest --cov=app --cov-report=html
```

Run specific test files:
```bash
pytest test_auth.py      # Authentication tests
pytest test_api.py        # API endpoint tests
pytest test_detection.py  # Detection system tests
```

**Test Results:** ✅ 20/20 tests passing

### Frontend Testing

Run frontend tests:
```bash
cd frontend
npm test
```

Run with coverage:
```bash
npm test -- --coverage --watchAll=false
```

### Documentation
- **Comprehensive Guide:** See [TESTING.md](TESTING.md)
- **Quick Reference:** See [QUICK_TEST_GUIDE.md](QUICK_TEST_GUIDE.md)
- **Implementation Details:** See [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)

---

## 📁 Project Structure

```
SecureExam-AI/
├── backend/
│   ├── app.py                    # Flask application (MongoDB integrated)
│   ├── requirements.txt          # Python dependencies
│   ├── yolov5n.pt               # YOLOv5 model (auto-downloaded)
│   └── yolov5nu.pt              # YOLOv5 model variant
│
├── frontend/
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── components/
│   │   │   ├── Exam.js          # Exam interface
│   │   │   ├── Instruction.js   # Pre-exam instructions
│   │   │   ├── Login.js         # Student login (with teacher link)
│   │   │   ├── NotFound.js
│   │   │   ├── ProtectedRoute.js
│   │   │   ├── TeacherProtectedRoute.js
│   │   ├── pages/
│   │   │   ├── ProctorDashboard.js   # Teacher dashboard
│   │   │   ├── TeacherLogin.js        # Teacher authentication
│   │   ├── utils/
│   │   │   └── keyboardRestriction.js
│   │   ├── App.js
│   │   └── index.js
│   └── package.json
│
├── testing/                     # Centralized testing folder
│   ├── backend/                 # Backend tests
│   │   ├── __init__.py
│   │   ├── conftest.py          # Pytest fixtures
│   │   ├── pytest.ini           # Pytest configuration
│   │   ├── test_auth.py         # Authentication tests
│   │   ├── test_api.py          # API tests
│   │   └── test_detection.py    # Detection tests
│   └── frontend/                # Frontend tests
│       ├── setupTests.js        # Jest configuration
│       ├── Login.test.js
│       ├── TeacherLogin.test.js
│       ├── Exam.test.js
│       └── ProctorDashboard.test.js
│
├── TESTING.md                   # Comprehensive testing guide
├── QUICK_TEST_GUIDE.md         # Quick test reference
├── IMPLEMENTATION_SUMMARY.md    # Implementation details
├── FEATURES.md                  # Feature documentation
├── README.md                    # This file
└── LICENSE
```

---

## 📚 Usage Guide

### Starting the Application

1. **Start Backend:**
   ```bash
   cd backend
   # Activate virtual environment first
   python app.py
   ```
   Backend runs on `http://localhost:5000`

2. **Start Frontend:**
   ```bash
   cd frontend
   npm start
   ```
   Frontend runs on `http://localhost:3000`

### Student Workflow

1. **Login** - Navigate to `http://localhost:3000`
   - Enter username, roll number, and password
   - Click "Login to Exam"

2. **Instructions** - Read exam rules and click "I Agree & Proceed"

3. **Face Registration** - Webcam captures face for verification

4. **Exam** - Take exam with AI monitoring:
   - Webcam tracks head movements
   - Detects forbidden objects (phones, laptops)
   - Monitors audio for speech
   - Answers auto-saved
   - Auto-submit on suspicious activity

5. **Results** - View score and percentage

### Teacher Workflow

1. **Login** - Click "Teacher/Proctor Login" on student login page
   - Use teacher credentials (see Authentication section)

2. **Dashboard** - Monitor all students:
   - View real-time alerts
   - See alert statistics
   - Filter by student or alert type
   - View charts and analytics

---

##  Authentication

### Teacher Accounts (MongoDB)
Default teacher accounts (created automatically):

| Username  | Password         | Role    |
|-----------|------------------|---------|
| admin     | SecureAdmin2026! | admin   |
| teacher   | TeacherPass2026! | teacher |
| proctor   | ProctorPass2026! | proctor |

**Note:** For development purposes, passwords are stored in plain text. For production, implement proper password hashing.

### Student Test Account

| Field       | Value         |
|-------------|---------------|
| Username    | test_student  |
| Roll Number | 12345         |
| Password    | password123   |

### Adding New Users

**Teachers:** Insert directly into MongoDB `teachers` collection:
```javascript
db.teachers.insertOne({
  username: "newteacher",
  password: "password",  // Plain text for development
  role: "teacher"
})
```

**Students:** Insert into `students` collection:
```javascript
db.students.insertOne({
  username: "student_name",
  roll_number: "ROLL123",
  password: "password"  // Consider hashing for production
})
```

---

## 📄 Documentation

- **[FEATURES.md](FEATURES.md)** - Complete feature list and API endpoints
- **[TESTING.md](TESTING.md)** - Comprehensive testing documentation
- **[QUICK_TEST_GUIDE.md](QUICK_TEST_GUIDE.md)** - Quick testing reference
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Implementation details and changes

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 🙏 Acknowledgments

- [YOLOv5 by Ultralytics](https://github.com/ultralytics/yolov5) - Object detection
- [MediaPipe](https://google.github.io/mediapipe/) - Face mesh and detection
- [React](https://reactjs.org/) - Frontend framework
- [Flask](https://flask.palletsprojects.com/) - Backend framework
- [MongoDB](https://www.mongodb.com/) - Database
- Open source community and contributors

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/your-username/SecureExam-AI/issues)
- **Repository:** [github.com/your-username/SecureExam-AI](https://github.com/your-username/SecureExam-AI)

---

**Last Updated:** February 2026
**Version:** 3.0 (Rebranded)
