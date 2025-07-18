<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Teacher Login</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <h2>Teacher Login</h2>
    <form action="TeacherLoginServlet" method="post">
        <label>Username:</label>
        <input type="text" name="username" required><br>
        <label>Password:</label>
        <input type="password" name="password" required><br>
        <button type="submit">Login</button>
        <div class="error">
            ${error}
        </div>
    </form>
    <a href="index.jsp">Back to Home</a>
</body>
</html>