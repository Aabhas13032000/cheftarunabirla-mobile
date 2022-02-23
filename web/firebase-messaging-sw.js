importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyD6VKqE5GbAh-koQA0oYFjrqSGDjTemI7A",
  authDomain: "tarunabirla-ef977.firebaseapp.com",
  projectId: "tarunabirla-ef977",
  storageBucket: "tarunabirla-ef977.appspot.com",
  messagingSenderId: "753457259745",
  appId: "1:753457259745:web:e2f54c729d0ac720b7c3a0",
  measurementId: "G-FL5LLG1WYL"
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});