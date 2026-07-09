function renderResults(data) {
  renderTotalVotes(data.total_votes);
  renderParticipantResults(data.participants);
  renderHourlyResults(data.hourly);
}

function renderTotalVotes(totalVotes) {
  const totalVotesElement = document.getElementById("totalVotes");
  totalVotesElement.textContent = `Total de votos: ${totalVotes}`;
}

function renderParticipantResults(participants) {
  const resultsContainer = document.getElementById("results");

  resultsContainer.innerHTML = participants
    .map((participant) => {
      return `
        <div class="mb-4">
          <div class="d-flex justify-content-between mb-1">
            <strong>${participant.name}</strong>
            <span>${participant.percentage}% (${participant.votes} votos)</span>
          </div>

          <div class="progress">
            <div
              class="progress-bar bg-secondary"
              role="progressbar"
              style="width: ${participant.percentage}%"
              aria-valuenow="${participant.percentage}"
              aria-valuemin="0"
              aria-valuemax="100">
              ${participant.percentage}%
            </div>
          </div>
        </div>
      `;
    })
    .join("");
}

function renderHourlyResults(hourly) {
  const hourlyContainer = document.getElementById("hourlyResults");

  if (!hourly || hourly.length === 0) {
    hourlyContainer.innerHTML = `<p class="text-secondary mb-0">Ainda não há votos por hora.</p>`;
    return;
  }

  hourlyContainer.innerHTML = `
    <div class="table-responsive">
      <table class="table table-sm align-middle mb-0">
        <thead>
          <tr>
            <th>Hora</th>
            <th>Total</th>
            <th>Participantes</th>
          </tr>
        </thead>

        <tbody>
          ${hourly
            .map((item) => {
              const participants = item.participants
                .map(
                  (participant) => `${participant.name}: ${participant.votes}`,
                )
                .join(" | ");

              return `
                <tr>
                  <td>${formatHour(item.hour)}</td>
                  <td>${item.total_votes}</td>
                  <td>${participants}</td>
                </tr>
              `;
            })
            .join("")}
        </tbody>
      </table>
    </div>
  `;
}

function formatHour(hour) {
  return new Intl.DateTimeFormat("pt-BR", {
    day: "2-digit",
    month: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  }).format(new Date(hour));
}
