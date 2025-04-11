import express from "express";
const app = express();
const port = 3000;

app.get("/", (req, res) => {
    res.send("Hello from App 2😊❤️!");
});

app.listen(port, () => {
    console.log(`App 2 listening on port ${port}`);
});
