import './App.css';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import Login from './components/Login';
import Exam from './components/Exam';
import Instruction from './components/Instruction';
import NotFound from './components/NotFound';
import MonitorDashboard from './pages/MonitorDashboard';
import TeacherLogin from './pages/TeacherLogin';
import TeacherProtectedRoute from './components/TeacherProtectedRoute';

function App() {
  const isTeacher = typeof window !== 'undefined' && localStorage.getItem('teacherLoggedIn') === 'true' && !!localStorage.getItem('teacherAuthToken');

  return (
    <div className="App">
      <Router>
        <header className="header">
          <div className="container">
            <div className="brand">
              <div className="logo">
                <img src="./logo.png" alt="AISAFEEXAM Logo" style={{ width: "50px", height: "50px" }} />
              </div>
              <div>AISAFEEXAM</div>
            </div>
            <nav className="nav">
              <Link to="/">Home</Link>
              <Link to="/instruction">Instructions</Link>
              <Link to="/exam">Exam</Link>
              {isTeacher && <Link to="/monitor-dashboard">Dashboard</Link>}
            </nav>
          </div>
        </header>

        <main className="main">
          <Routes>
            <Route path='/' element={<Login />} />
            <Route path='/exam' element={<Exam />} />
            <Route path='/instruction' element={<Instruction />} />
            <Route path="/teacher/login" element={<TeacherLogin />} />
            <Route path="/monitor-dashboard" element={
              <TeacherProtectedRoute>
                <MonitorDashboard />
              </TeacherProtectedRoute>
            } />
            <Route path="*" element={<NotFound />} />
          </Routes>
        </main>
      </Router>
    </div>
  );
}

export default App;
