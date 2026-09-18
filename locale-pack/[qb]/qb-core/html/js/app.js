let NOTIFY_CONFIG = null;

const defaultConfig = {
    NotificationStyling: {
        group: false,
        position: "right",
        progress: true,
    },
    VariantDefinitions: {
        success: { classes: "success", icon: "check_circle" },
        primary: { classes: "primary", icon: "notifications" },
        warning: { classes: "warning", icon: "warning" },
        error: { classes: "error", icon: "error" },
        police: { classes: "police", icon: "local_police" },
        ambulance: { classes: "ambulance", icon: "fas fa-ambulance" },
    },
};

const fetchNui = async (evName, data) => {
    const resourceName = window.GetParentResourceName();
    const resp = await fetch(`https://${resourceName}/${evName}`, {
        body: JSON.stringify(data),
        headers: { "Content-Type": "application/json; charset=UTF8" },
        method: "POST",
    });
    return resp.json();
};

const determineStyleFromVariant = (variant) => {
    return NOTIFY_CONFIG.VariantDefinitions[variant] ?? NOTIFY_CONFIG.VariantDefinitions["primary"];
};

const fetchNotifyConfig = async () => {
    try {
        NOTIFY_CONFIG = await fetchNui("getNotifyConfig", {});
        if (!NOTIFY_CONFIG) NOTIFY_CONFIG = defaultConfig;
    } catch (error) {
        console.error("Failed to fetch notification config, using default", error);
        NOTIFY_CONFIG = defaultConfig;
    }
};

const POSITION_MAP = {
    "top-left": { top: "16px", left: "16px" },
    "top-right": { top: "16px", right: "16px" },
    top: { top: "16px", left: "50%", transform: "translateX(-50%)" },
    "bottom-left": { bottom: "16px", left: "16px" },
    "bottom-right": { bottom: "16px", right: "16px" },
    bottom: { bottom: "6vh", left: "50%", transform: "translateX(-50%)" },
    left: { top: "50%", left: "16px", transform: "translateY(-50%)" },
    right: { top: "50%", right: "16px", transform: "translateY(-50%)" },
    center: { top: "50%", left: "50%", transform: "translate(-50%, -50%)" },
};

const containers = {};

const getContainer = (position) => {
    if (containers[position]) return containers[position];
    const pos = position ?? "right";
    const isBottom = pos.startsWith("bottom");
    const box = document.createElement("div");
    box.id = "notify-container-" + pos;
    Object.assign(box.style, {
        position: "fixed",
        display: "flex",
        flexDirection: isBottom ? "column-reverse" : "column",
        gap: "8px",
        zIndex: "9999",
        maxWidth: "400px",
        pointerEvents: "none",
        ...(POSITION_MAP[pos] ?? POSITION_MAP["right"]),
    });
    document.body.appendChild(box);
    containers[position] = box;
    return box;
};

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// Уведомления уходят по очереди: самое нижнее первым, каждое следующее —
// через две секунды. Иначе пачка исчезает разом и игрок не успевает прочитать.
const REMOVE_GAP = 2000;
const drainState = new WeakMap();

const drainContainer = (container) => {
    let state = drainState.get(container);
    if (!state) {
        state = { locked: false };
        drainState.set(container, state);
    }
    if (state.locked) return;

    const first = container.firstElementChild;
    if (!first) return;
    if (Number(first.dataset.readyAt || 0) > Date.now()) return;

    state.locked = true;
    first.classList.remove("notify-show");
    first.classList.add("notify-hide");
    setTimeout(() => first.remove(), 350);
    setTimeout(() => {
        state.locked = false;
        drainContainer(container);
    }, REMOVE_GAP);
};

const showNotif = async ({ data }) => {
    if (data?.action !== "notify") return;

    if (!NOTIFY_CONFIG) {
        await fetchNotifyConfig();
    }

    const { text: message, type, length: duration = 5000, caption, position } = data;
    const style = determineStyleFromVariant(type ?? "primary");
    const stay = Math.max(duration, 5000);
    const showProgress = NOTIFY_CONFIG.NotificationStyling.progress && duration > 0;

    const isFa = style.icon.startsWith("fa");
    const iconHtml = isFa ? `<i class="notify-icon ${style.icon}"></i>` : `<span class="notify-icon material-icons">${style.icon}</span>`;

    const item = document.createElement("div");
    item.className = `notify-item ${style.classes}`;
    item.innerHTML = `
        ${iconHtml}
        <div class="notify-content">
            <div class="notify-message${!caption ? " notify-multiline" : ""}">${message}</div>
            ${caption ? `<div class="notify-caption">${caption}</div>` : ""}
        </div>
        ${showProgress ? `<div class="notify-progress" style="animation-duration:${stay}ms"></div>` : ""}
    `;

    const c = getContainer(position ?? NOTIFY_CONFIG.NotificationStyling.position ?? "right");
    c.appendChild(item);

    await sleep(10);
    item.classList.add("notify-show");

    if (stay > 0) {
        item.dataset.readyAt = Date.now() + stay;
        setTimeout(() => drainContainer(c), stay + 50);
    }
};

window.addEventListener("message", showNotif);
window.addEventListener("load", fetchNotifyConfig);
