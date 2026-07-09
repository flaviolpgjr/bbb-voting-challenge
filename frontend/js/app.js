let renderedAt = Date.now();

document.addEventListener("DOMContentLoaded", async () => {
  try {
    const data = await getResults();

    renderParticipants(data.participants);
    bindVoteButton();
    bindVoteAgainButton();
  } catch (error) {
    showError(error.message);
  }
});

function bindVoteAgainButton() {
  const button = document.getElementById("voteAgainButton");

  if (!button) return;

  button.addEventListener("click", () => {
    renderedAt = Date.now();
    showVotingScreen();
  });
}
