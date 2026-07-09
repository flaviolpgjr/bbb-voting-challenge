const API_BASE_URL = "/api/v1";

async function getResults() {
  const response = await fetch(`${API_BASE_URL}/results`);

  if (!response.ok) {
    throw new Error("Não foi possível carregar os resultados.");
  }

  return response.json();
}

async function createVote(participantId) {
  const response = await fetch(`${API_BASE_URL}/votes`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      participant_id: participantId,
      website: document.getElementById("website").value,
      rendered_at: renderedAt,
    }),
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.error || "Não foi possível computar o voto.");
  }

  return data;
}
