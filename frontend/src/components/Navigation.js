import React, { useState, useEffect } from 'react';
import { Navbar, Nav, Container } from 'react-bootstrap';
import { Link, useLocation } from 'react-router-dom';
import { 
  Home, 
  Briefcase, 
  Users,
  MessageSquare, 
  FileText, 
  Menu 
} from 'react-feather';

function Navigation() {
  const location = useLocation();
  const [expanded, setExpanded] = useState(false);
  const [isMobile, setIsMobile] = useState(window.innerWidth < 992);

  useEffect(() => {
    const handleResize = () => {
      setIsMobile(window.innerWidth < 992);
      if (window.innerWidth >= 992) {
        setExpanded(false);
      }
    };

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const navLinks = [
    { to: "/", icon: <Home size={20} />, label: "Dashboard" },
    { to: "/projects", icon: <Briefcase size={20} />, label: "Projects" },
    { to: "/sessions", icon: <Users size={20} />, label: "Sessions" },
    { to: "/channels", icon: <MessageSquare size={20} />, label: "Channels" },
    { to: "/files", icon: <FileText size={20} />, label: "Files" },
  ];

  const closeNav = () => setExpanded(false);

  if (isMobile) {
    return (
      <div className="mobile-nav">
        <div className="mobile-nav-items">
          {navLinks.map((link) => (
            <Link
              key={link.to}
              to={link.to}
              className={`mobile-nav-item ${location.pathname === link.to ? 'active' : ''}`}
              onClick={closeNav}
            >
              <div className="nav-icon">
                {React.cloneElement(link.icon, {
                  color: location.pathname === link.to ? '#4e73df' : '#6c757d',
                })}
              </div>
              <span className="nav-label">{link.label}</span>
            </Link>
          ))}
        </div>
      </div>
    );
  }

  return (
    <>
      <Navbar 
        bg="white" 
        expand="lg" 
        className="shadow-sm"
        expanded={expanded}
        onToggle={() => setExpanded(!expanded)}
      >
        <Container fluid>
          <Navbar.Brand as={Link} to="/" className="fw-bold text-primary">
            <span className="d-flex align-items-center">
              <span className="me-2">📱</span>
              <span>Telegram Manager</span>
            </span>
          </Navbar.Brand>
          <Navbar.Toggle aria-controls="main-navbar-nav" className="border-0">
            <Menu size={24} />
          </Navbar.Toggle>
          <Navbar.Collapse id="main-navbar-nav">
            <Nav className="ms-auto">
              {navLinks.map((link) => (
                <Nav.Link 
                  key={link.to}
                  as={Link} 
                  to={link.to}
                  className={`d-flex align-items-center mx-2 ${location.pathname === link.to ? 'active' : ''}`}
                  onClick={closeNav}
                >
                  <span className="me-2">{link.icon}</span>
                  {link.label}
                </Nav.Link>
              ))}
            </Nav>
          </Navbar.Collapse>
        </Container>
      </Navbar>
      <div className="mobile-nav-spacer"></div>
    </>
  );
}

export default Navigation;