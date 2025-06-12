const transactionService = require('./TransactionService');
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = 4000;

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(cors());

// Health Check
app.get('/health', (req, res) => {
    res.json("This is the health check");
});

// ADD TRANSACTION
app.post('/transaction', (req, res) => {
    try {
        const { amount, desc } = req.body;
        console.log("Request Body:", req.body);

        transactionService.addTransaction(amount, desc);
        res.status(200).json({ message: 'Transaction added successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Something went wrong', error: err.message });
    }
});

// GET ALL TRANSACTIONS
app.get('/transaction', (req, res) => {
    try {
        transactionService.getAllTransactions(function (results) {
            const transactionList = results.map(row => ({
                id: row.id,
                amount: row.amount,
                description: row.description
            }));
            res.status(200).json({ result: transactionList });
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Could not get all transactions", error: err.message });
    }
});

// DELETE ALL TRANSACTIONS
app.delete('/transaction', (req, res) => {
    try {
        transactionService.deleteAllTransactions(() => {
            res.status(200).json({ message: "All transactions deleted." });
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Failed to delete all transactions", error: err.message });
    }
});

// DELETE ONE TRANSACTION BY ID
app.delete('/transaction/:id', (req, res) => {
    const id = req.params.id;
    try {
        transactionService.deleteTransactionById(id, () => {
            res.status(200).json({ message: `Transaction with id ${id} deleted.` });
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Failed to delete transaction", error: err.message });
    }
});

// GET SINGLE TRANSACTION BY ID
app.get('/transaction/:id', (req, res) => {
    const id = req.params.id;
    try {
        transactionService.findTransactionById(id, (result) => {
            if (!result || result.length === 0) {
                return res.status(404).json({ message: "Transaction not found" });
            }

            const { id, amount, description } = result[0];
            res.status(200).json({ id, amount, description });
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Failed to retrieve transaction", error: err.message });
    }
});

// Start server
app.listen(port, () => {
    console.log(`Backend app running at http://localhost:${port}`);
});
