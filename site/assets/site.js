const search = document.querySelector("#search");
const filters = document.querySelector(".filters");
const cards = [...document.querySelectorAll(".report-card")];
const resultCount = document.querySelector("#result-count");
let activeFilter = "all";

function updateResults() {
  const searchTerm = search.value.trim().toLocaleLowerCase();
  let visible = 0;
  for (const card of cards) {
    const matchesSearch = card.dataset.search.toLocaleLowerCase().includes(searchTerm);
    const matchesFilter = activeFilter === "all" || card.dataset.category === activeFilter;
    const show = matchesSearch && matchesFilter;
    card.hidden = !show;
    if (show) visible += 1;
  }
  resultCount.textContent = `${visible} report${visible === 1 ? "" : "s"}`;
}

search?.addEventListener("input", updateResults);
filters?.addEventListener("click", (event) => {
  const button = event.target.closest("button[data-filter]");
  if (!button) return;
  activeFilter = button.dataset.filter;
  for (const filter of filters.querySelectorAll("button")) {
    filter.setAttribute("aria-pressed", String(filter === button));
  }
  updateResults();
});
