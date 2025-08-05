const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

// Set email and password of the sender Gmail (App Password recommended)
const gmailEmail = "kotalakshmipriya348@gmail.com";
const gmailPassword = "Priya@1605"; // Replace with your App Password

// Configure mail transporter
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: gmailEmail,
    pass: gmailPassword,
  },
});

// Cloud Function to send email when a new problem is submitted
exports.sendProblemEmail = functions.firestore
    .document("problems/{problemId}")
    .onCreate(async (snap, context) => {
      const data = snap.data();

      const mailOptions = {
        from: `Women Empowerment App <${gmailEmail}>`,
        to: gmailEmail, // Admin receives the email
        subject: "🚨 New Problem Submitted",
        html: `
        <h2>New Problem Submitted</h2>
        <p><strong>Name:</strong> ${data.name}</p>
        <p><strong>Email:</strong> ${data.email}</p>
        <p><strong>Phone:</strong> ${data.phone}</p>
        <p><strong>Problem:</strong> ${data.problem}</p>
        <br />
        <p>This message was automatically sent by the Women Empowerment App.</p>
      `,
      };

      try {
        await transporter.sendMail(mailOptions);
        console.log("✅ Email sent successfully.");
      } catch (error) {
        console.error("❌ Error sending email:", error);
      }
    });
