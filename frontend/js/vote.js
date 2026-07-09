function renderParticipants(participants) {
  const container = document.getElementById("participants");

  container.innerHTML = participants
    .map((participant) => {
      return `
        <div class="col-md-6">
          <div
            class="card shadow-sm h-100 participant-card"
            data-participant-id="${participant.id}"
          >
            <div class="card-body">
              <div class="form-check">
                <input
                  class="form-check-input"
                  type="radio"
                  name="participant"
                  id="participant-${participant.id}"
                  value="${participant.id}"
                >

                <label
                  class="form-check-label fs-5"
                  for="participant-${participant.id}">
                  ${participant.name}
                </label>
              </div>
            </div>
          </div>
        </div>
      `;
    })
    .join("");

  bindParticipantCards();
}

function bindParticipantCards() {
  document.querySelectorAll(".participant-card").forEach((card) => {
    card.addEventListener("click", () => {
      const participantId = card.dataset.participantId;
      const radio = document.getElementById(`participant-${participantId}`);

      radio.checked = true;

      document.querySelectorAll(".participant-card").forEach((item) => {
        item.classList.remove("border-primary", "selected-card");
      });

      card.classList.add("border-primary", "selected-card");
    });
  });
}

async function handleVote() {
  const selectedParticipant = document.querySelector(
    'input[name="participant"]:checked',
  );

  if (!selectedParticipant) {
    showError("Selecione um participante antes de votar.");
    return;
  }

  const voteButton = document.getElementById("voteButton");

  try {
    voteButton.disabled = true;
    voteButton.textContent = "Computando voto...";

    await createVote(selectedParticipant.value);

    const results = await getResults();

    renderResults(results);
    showResultScreen();
  } catch (error) {
    showError(error.message);
  } finally {
    voteButton.disabled = false;
    voteButton.textContent = "Votar";
  }
}

function bindVoteButton() {
  const voteButton = document.getElementById("voteButton");

  if (!voteButton) {
    console.error("voteButton not found");
    return;
  }

  voteButton.addEventListener("click", handleVote);
}
