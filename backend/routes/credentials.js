const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { db } = require('../db');
const router = express.Router();

// POST /api/credentials - store api_id/api_hash
router.post('/', (req, res) => {
  const { name, api_id, api_hash, owner } = req.body;
  const id = uuidv4();
  
  if (!api_id || !api_hash) {
    return res.status(400).json({ success: false, error: 'API ID and API hash are required' });
  }
  
  // Check if there's already an active credential
  db.get('SELECT COUNT(*) as count FROM api_credentials WHERE is_active = 1', [], (err, row) => {
    if (err) {
      return res.status(500).json({ success: false, error: err.message });
    }
    
    // If there's already an active credential, set new one as inactive
    const isActive = row.count === 0 ? 1 : 0;
    
    const sql = 'INSERT INTO api_credentials (id, name, api_id, api_hash, owner, is_active) VALUES (?, ?, ?, ?, ?, ?)';
    db.run(sql, [id, name || 'Default', api_id, api_hash, owner || null, isActive], function(err) {
      if (err) {
        return res.status(500).json({ success: false, error: err.message });
      }
      res.status(201).json({ 
        success: true, 
        data: { id, name: name || 'Default', api_id, api_hash, owner: owner || null, is_active: isActive },
        message: isActive ? 'Credential saved and activated' : 'Credential saved as inactive. Activate it to use.'
      });
    });
  });
});

// GET /api/credentials - list credentials
router.get('/', (req, res) => {
  const sql = 'SELECT id, name, api_id, api_hash, owner, is_active FROM api_credentials ORDER BY name ASC';
  db.all(sql, [], (err, rows) => {
    if (err) {
      return res.status(500).json({ success: false, error: err.message });
    }
    res.json({ success: true, data: rows });
  });
});

// GET /api/credentials/active - get the active credential (if any)
router.get('/active', (req, res) => {
  const sql = 'SELECT id, name, api_id, api_hash, owner, is_active FROM api_credentials WHERE is_active = 1 LIMIT 1';
  db.get(sql, [], (err, row) => {
    if (err) {
      return res.status(500).json({ success: false, error: err.message });
    }
    res.json({ success: true, data: row || null });
  });
});

// PUT /api/credentials/:id/activate - set a credential as active (and deactivate others)
router.put('/:id/activate', (req, res) => {
  const { id } = req.params;
  
  // First check if credential exists
  db.get('SELECT id FROM api_credentials WHERE id = ?', [id], (err, row) => {
    if (err) {
      return res.status(500).json({ success: false, error: err.message });
    }
    if (!row) {
      return res.status(404).json({ success: false, error: 'Credential not found' });
    }
    
    // Use transaction to ensure atomicity
    db.serialize(() => {
      db.run('BEGIN TRANSACTION');
      
      db.run('UPDATE api_credentials SET is_active = 0', [], function(err) {
        if (err) {
          db.run('ROLLBACK');
          return res.status(500).json({ success: false, error: err.message });
        }
        
        db.run('UPDATE api_credentials SET is_active = 1 WHERE id = ?', [id], function(err2) {
          if (err2) {
            db.run('ROLLBACK');
            return res.status(500).json({ success: false, error: err2.message });
          }
          
          db.run('COMMIT');
          return res.json({ success: true, message: 'Credential activated successfully' });
        });
      });
    });
  });
});

// DELETE /api/credentials/:id - delete a credential
router.delete('/:id', (req, res) => {
  const { id } = req.params;
  const sql = 'DELETE FROM api_credentials WHERE id = ?';
  db.run(sql, [id], function(err) {
    if (err) {
      return res.status(500).json({ success: false, error: err.message });
    }
    if (this.changes === 0) {
      return res.status(404).json({ success: false, error: 'Credential not found' });
    }
    res.json({ success: true, message: 'Credential deleted successfully' });
  });
});

module.exports = router;