const express = require('express');
const Document = require('../models/document');
const auth = require('../middlewares/auth');
const documentRouter = express.Router();

documentRouter.post('/doc/create', auth, async (req, res) => {
    try {
        const { createdAt } = req.body;
        
        console.log(`Gelen istek: ${req.method} ${req.url}`);
        console.log('Gövde:', req.body);  // Gelen JSON'u logla

        let document = new Document({
            uid: req.user,
            title: 'Untitled Document',
            createdAt,
        });

        console.log('Oluşturulan belge:', document);

        document = await document.save();
        console.log('Kaydedilen belge:', document);

        res.json(document);
    } catch (error) {
        console.error('Hata:', error.message);
        res.status(500).json({ error: error.message });
    }
});


documentRouter.get('/docs/me', auth, async (req, res) => {
    try {
        let documents = await Document.find({ uid: req.user });
        if (!documents || documents.length === 0) {
            return res.status(404).json({ error: 'No documents found for this user.' });
        }
        res.json(documents);
    } catch (e) {
        console.error('Belge sorgulama hatası:', e.message);
        res.status(500).json({ error: 'Internal server error. Please try again later.' });
    }
});



// Belge başlığını güncelleme
documentRouter.post('/doc/title', auth, async (req, res) => {
    try {
        const { id, title } = req.body;
        console.log(`Gelen istek: ${req.method} ${req.url}`);
        console.log('Gövde:', req.body);  // Gelen JSON'u logla

        const document = await Document.findByIdAndUpdate(id, { title });
        console.log('Güncellenen belge:', document);

        res.json(document);
    } catch (error) {
        console.error('Hata:', error.message);
        res.status(500).json({ error: error.message });
    }
});
documentRouter.get('/doc/:id', auth, async (req, res) => {
    try {
        console.log(`Gelen istek: ${req.method} ${req.url}`);
        const documents = await Document.findById(req.params.id);
        console.log('Bulunan belge:', documents);
        res.json(documents);
    } catch (error) {
        console.error('Hata:', error.message);
        res.status(500).json({ error: error.message });
    }
});


module.exports = documentRouter;