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
        console.log(`Gelen istek: ${req.method} ${req.url}`);

        let documents = await Document.find({ uid: req.user });
        console.log('Kullanıcı belgeleri:', documents);
        res.json(documents);
    } catch (e) {
        console.error('Hata:', e.message);
        res.status(500).json({ error: e.message });
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
documentRouter.get('/docs/:id', auth, async (req, res) => {
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