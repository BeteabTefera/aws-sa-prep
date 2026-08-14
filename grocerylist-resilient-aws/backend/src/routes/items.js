const express = require('express');
const fs = require('fs');
const path = require('path');

const router = express.Router();
const DATA_FILE = path.join(__dirname, '../data/items.json');

function readItems() {
  return JSON.parse(fs.readFileSync(DATA_FILE, 'utf-8'));
}

function writeItems(items) {
  fs.writeFileSync(DATA_FILE, JSON.stringify(items, null, 2));
}

// GET all items
router.get('/', (req, res) => {
  res.json(readItems());
});

// POST new item
router.post('/', (req, res) => {
  const { name, category } = req.body;
  if (!name) return res.status(400).json({ error: 'name is required' });

  const items = readItems();
  const newItem = {
    id: Date.now().toString(),
    name,
    category: category || 'uncategorized',
    bought: false,
  };
  items.push(newItem);
  writeItems(items);
  res.status(201).json(newItem);
});

// PATCH toggle bought status
router.patch('/:id', (req, res) => {
  const items = readItems();
  const item = items.find((i) => i.id === req.params.id);
  if (!item) return res.status(404).json({ error: 'not found' });

  if (typeof req.body.bought === 'boolean') item.bought = req.body.bought;
  writeItems(items);
  res.json(item);
});

// DELETE item
router.delete('/:id', (req, res) => {
  let items = readItems();
  const exists = items.some((i) => i.id === req.params.id);
  if (!exists) return res.status(404).json({ error: 'not found' });

  items = items.filter((i) => i.id !== req.params.id);
  writeItems(items);
  res.status(204).send();
});

module.exports = router;