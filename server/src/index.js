const Koa = require("koa");
const app = new Koa();
const server = require("http").createServer(app.callback());
const WebSocket = require("ws");
const wss = new WebSocket.Server({ server });
const Router = require("@koa/router");
const cors = require("@koa/cors");
const bodyParser = require("koa-bodyparser");

app.use(bodyParser());
app.use(cors());
app.use(middleware);

async function middleware(ctx, next) {
    const start = new Date();
    try {
        console.log(`[REQ] ${ctx.request.method} ${ctx.request.url}`);
        if (ctx.request.body && Object.keys(ctx.request.body).length > 0) {
            console.log(`[REQ] Payload:`, ctx.request.body);
        }
        await next();
    } catch (err) {
        ctx.status = err.status || 500;
        ctx.body = { error: err.message };
        console.error(`[ERROR] ${ctx.status} ${ctx.request.method} ${ctx.request.url} - Cause: ${err.message}`, err);
    } finally {
        const ms = new Date() - start;
        console.log(`[RES] ${start.toLocaleTimeString()} ${ctx.status} ${ctx.request.method} ${ctx.request.url} - ${ms}ms`);
    }
}

const fees = [
    { id: 1, date: "2026-01-15", amount: 15.00, type: "fine", category: "late_return", description: "Late return of Gatsby" },
    { id: 2, date: "2026-01-10", amount: 50.00, type: "membership", category: "annual", description: "Annual membership" },
    { id: 3, date: "2025-12-20", amount: 10.00, type: "service", category: "printing", description: "Thesis printing" },
];

const router = new Router();

router.get("/fees", async (ctx) => {
    ctx.body = fees;
    ctx.status = 200;
});

router.get("/fee/:id", async (ctx) => {
    const id = parseInt(ctx.params.id);
    const item = fees.find((t) => t.id === id);
    if (item) {
        ctx.body = item;
        ctx.status = 200;
    } else {
        ctx.throw(404, "Fee not found");
    }
});

router.post("/fee", async (ctx) => {
    const { date, amount, type, category, description } = ctx.request.body;
    if (!date || !amount || !type) {
        ctx.throw(400, "Missing required fields");
    }
    const newFee = {
        id: Math.max(...fees.map((t) => t.id), 0) + 1,
        date,
        amount: parseFloat(amount),
        type,
        category: category || "general",
        description: description || ""
    };
    fees.push(newFee);
    broadcast(newFee);
    ctx.body = newFee;
    ctx.status = 201;
});

router.del("/fee/:id", async (ctx) => {
    const id = parseInt(ctx.params.id);
    const idx = fees.findIndex((t) => t.id === id);
    if (idx === -1) {
        ctx.throw(404, "Fee not found");
    }
    const deleted = fees.splice(idx, 1)[0];
    ctx.body = deleted;
    ctx.status = 200;
});

router.get("/allFees", async (ctx) => {
    ctx.body = fees;
    ctx.status = 200;
});

function broadcast(data) {
    wss.clients.forEach((client) => {
        if (client.readyState === WebSocket.OPEN) {
            client.send(JSON.stringify(data));
        }
    });
}

app.use(router.routes());
app.use(router.allowedMethods());

const port = 2620;
server.listen(port, () => {
    console.log(`Fee Server running on port ${port}... 🚀`);
});
