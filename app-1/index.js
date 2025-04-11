import express from "express";
const app = express();
const port = 3000;

app.get("/", (req, res) => {
    res.send("Hello from App 1😊✅❤️!");
});

app.listen(port, () => {
    console.log(`App 1 listening on port ${port}`);
});
