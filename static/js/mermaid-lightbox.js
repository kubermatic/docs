const CSS = `
.mermaid { cursor: zoom-in; }
.mermaid svg { max-width: 100%; height: auto; }
.mermaid::after {
  content: "\\2922  Click to enlarge";
  display: block;
  margin-top: .35rem;
  font: 12px/1.4 system-ui, -apple-system, sans-serif;
  color: #8a8a8a;
}
#mermaid-lightbox { position: fixed; inset: 0; z-index: 10000; background: #fbfbfb; display: none; }
#mermaid-lightbox.is-open { display: block; }
#mermaid-lightbox .ml-stage { position: absolute; inset: 0; overflow: hidden; cursor: grab; }
#mermaid-lightbox .ml-stage.is-dragging { cursor: grabbing; }
#mermaid-lightbox .ml-stage svg {
  position: absolute; top: 0; left: 0;
  transform-origin: 0 0; max-width: none; height: auto;
}
#mermaid-lightbox .ml-bar { position: absolute; top: 14px; right: 18px; z-index: 2; display: flex; gap: 6px; }
#mermaid-lightbox .ml-bar button {
  min-width: 38px; padding: 7px 11px;
  font: 500 14px/1 system-ui, -apple-system, sans-serif; color: #222;
  background: #fff; border: 1px solid #d5d5d5; border-radius: 6px; cursor: pointer;
}
#mermaid-lightbox .ml-bar button:hover { background: #f0f0f0; }
#mermaid-lightbox .ml-hint {
  position: absolute; bottom: 16px; left: 18px;
  font: 13px/1.4 system-ui, -apple-system, sans-serif; color: #777;
}
@media print { .mermaid::after { display: none; } #mermaid-lightbox { display: none !important; } }
`;

const MIN_SCALE = 0.1;
const MAX_SCALE = 20;
const FIT_PADDING = 56;

function buildOverlay() {
  const style = document.createElement("style");
  style.textContent = CSS;
  document.head.appendChild(style);

  const box = document.createElement("div");
  box.id = "mermaid-lightbox";
  box.innerHTML = `
    <div class="ml-bar">
      <button type="button" data-act="out" aria-label="Zoom out">&minus;</button>
      <button type="button" data-act="in" aria-label="Zoom in">+</button>
      <button type="button" data-act="fit">Fit</button>
      <button type="button" data-act="close" aria-label="Close">Close &times;</button>
    </div>
    <div class="ml-stage"></div>
    <div class="ml-hint">Scroll to zoom &middot; drag to pan &middot; Esc to close</div>`;
  document.body.appendChild(box);
  return box;
}

export function initMermaidLightbox() {
  const diagrams = document.querySelectorAll(".mermaid");
  if (!diagrams.length) return;

  const box = buildOverlay();
  const stage = box.querySelector(".ml-stage");
  let svg = null;
  let scale = 1;
  let tx = 0;
  let ty = 0;
  let naturalWidth = 0;
  let naturalHeight = 0;

  const apply = () => {
    if (svg) svg.style.transform = `translate(${tx}px, ${ty}px) scale(${scale})`;
  };

  const zoomAbout = (factor, cx, cy) => {
    const next = Math.min(Math.max(scale * factor, MIN_SCALE), MAX_SCALE);
    tx = cx - (cx - tx) * (next / scale);
    ty = cy - (cy - ty) * (next / scale);
    scale = next;
    apply();
  };

  const fit = () => {
    if (!naturalWidth || !naturalHeight) return;
    scale = Math.min(
      (window.innerWidth - FIT_PADDING * 2) / naturalWidth,
      (window.innerHeight - FIT_PADDING * 2) / naturalHeight,
      4,
    );
    tx = (window.innerWidth - naturalWidth * scale) / 2;
    ty = (window.innerHeight - naturalHeight * scale) / 2;
    apply();
  };

  const open = (source) => {
    stage.innerHTML = "";
    svg = source.cloneNode(true);

    // Mermaid scopes its generated CSS to the SVG's own id (`#mermaid-123 .node rect`).
    // Re-point the clone's rules at a fresh id so the copy keeps its styling without
    // duplicating an id already in the document.
    const sourceId = source.getAttribute("id");
    if (sourceId) {
      const cloneId = `${sourceId}-lightbox`;
      svg.setAttribute("id", cloneId);
      svg.querySelectorAll("style").forEach((sheet) => {
        sheet.textContent = sheet.textContent.split(`#${sourceId}`).join(`#${cloneId}`);
      });
    }

    const viewBox = (svg.getAttribute("viewBox") || "").split(/[\s,]+/).map(Number);
    const measured = source.getBoundingClientRect();
    naturalWidth = viewBox.length === 4 && viewBox[2] ? viewBox[2] : measured.width;
    naturalHeight = viewBox.length === 4 && viewBox[3] ? viewBox[3] : measured.height;

    svg.setAttribute("width", naturalWidth);
    svg.setAttribute("height", naturalHeight);
    svg.style.maxWidth = "none";

    stage.appendChild(svg);
    box.classList.add("is-open");
    document.body.style.overflow = "hidden";
    fit();
  };

  const close = () => {
    box.classList.remove("is-open");
    document.body.style.overflow = "";
    stage.innerHTML = "";
    svg = null;
  };

  diagrams.forEach((node) => {
    node.setAttribute("title", "Click to enlarge");
    node.addEventListener("click", () => {
      const rendered = node.querySelector("svg");
      if (rendered) open(rendered);
    });
  });

  box.querySelector(".ml-bar").addEventListener("click", (event) => {
    const act = event.target.closest("button")?.dataset.act;
    if (act === "close") close();
    if (act === "fit") fit();
    if (act === "in") zoomAbout(1.25, window.innerWidth / 2, window.innerHeight / 2);
    if (act === "out") zoomAbout(1 / 1.25, window.innerWidth / 2, window.innerHeight / 2);
  });

  stage.addEventListener(
    "wheel",
    (event) => {
      event.preventDefault();
      zoomAbout(event.deltaY < 0 ? 1.12 : 1 / 1.12, event.clientX, event.clientY);
    },
    { passive: false },
  );

  let dragging = false;
  let moved = false;
  let originX = 0;
  let originY = 0;

  stage.addEventListener("pointerdown", (event) => {
    dragging = true;
    moved = false;
    originX = event.clientX - tx;
    originY = event.clientY - ty;
    stage.classList.add("is-dragging");
    stage.setPointerCapture(event.pointerId);
  });

  stage.addEventListener("pointermove", (event) => {
    if (!dragging) return;
    moved = true;
    tx = event.clientX - originX;
    ty = event.clientY - originY;
    apply();
  });

  const endDrag = () => {
    dragging = false;
    stage.classList.remove("is-dragging");
  };
  stage.addEventListener("pointerup", endDrag);
  stage.addEventListener("pointercancel", endDrag);

  stage.addEventListener("click", (event) => {
    if (!moved && event.target === stage) close();
  });

  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && box.classList.contains("is-open")) close();
  });

  window.addEventListener("resize", () => {
    if (box.classList.contains("is-open")) fit();
  });
}
