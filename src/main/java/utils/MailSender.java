package utils;

import java.util.Properties;
import java.util.Random;

import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

public class MailSender {

	private final Session session;
    private static final String HOST = "sandbox.smtp.mailtrap.io";
    private static final int PORT = 587; 
    private static final String USERNAME = "b446637b2bc21e"; 
    private static final String PASSWORD = "98f685f4b22244"; 
    private static final String FROM_EMAIL = "noreply@petshop.com";

	public MailSender() {
     Properties props = new Properties();
     props.put("mail.smtp.host", HOST);
     props.put("mail.smtp.port", String.valueOf(PORT));
     props.put("mail.smtp.auth", "true");
     props.put("mail.smtp.ssl.protocols", "TLSv1.2");
     props.put("mail.smtp.starttls.enable", "true"); 
     props.put("mail.smtp.connectiontimeout", "10000");
     props.put("mail.smtp.timeout", "10000");
     props.put("mail.smtp.user", USERNAME); 

     this.session = Session.getInstance(props, new Authenticator() {
         @Override protected PasswordAuthentication getPasswordAuthentication() {
             return new PasswordAuthentication(USERNAME, PASSWORD);
         }
     });
    }

	public void sendHtml(String to, String subject, String html) throws MessagingException {
		Message msg = new MimeMessage(session);
		msg.setFrom(new InternetAddress(FROM_EMAIL));
		msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
		msg.setSubject(subject);
		msg.setContent(html, "text/html; charset=UTF-8");
		Transport.send(msg);
	}

    public static String generate2FACode() {
        Random random = new Random();
        int code = 100000 + random.nextInt(900000);
        return String.valueOf(code);
    }
}