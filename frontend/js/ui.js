function showVotingScreen() {
  document.getElementById("votingScreen").classList.remove("d-none");
  document.getElementById("resultScreen").classList.add("d-none");
}

function showResultScreen() {
  document.getElementById("votingScreen").classList.add("d-none");
  document.getElementById("resultScreen").classList.remove("d-none");
}

function showError(message) {
  alert(message);
}
