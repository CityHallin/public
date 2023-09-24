
//On "send" button push
async function send() {

  //Get user Answer
  var answer = document.getElementById("userAnswerBox").value;

  //Update text areas
  document.getElementById("userAnswerBox").value = "";
  document.getElementById("displayBox").value = "Checking your answer...";

  //HTTP POST to EBS checking answer
  const response = fetch("https://<AZURE APIM NAME HERE>.azure-api.net/<API PATH HERE>", {
    method: "POST",
    headers: {
      Authorization:`Bearer ${token}`,
      mode: "cors",
      "Content-Type": "application/json",
    },
    body: JSON.stringify(answer),
  })
  .then(response => response.text())    
  .then(data => {
      document.getElementById("displayBox").value = `${data}`;      
  })

}