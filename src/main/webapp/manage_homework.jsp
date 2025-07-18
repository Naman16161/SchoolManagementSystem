<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("teacherId") == null) {
        response.sendRedirect("teacher_login.jsp");
        return;
    }
    String selectedClass = request.getParameter("class");
    if (selectedClass == null) selectedClass = "";

    // Fetch all classes for dropdown
    List<String> classes = new ArrayList<>();
    try {
        Connection conn = util.DBConnection.getConnection();
        Statement st = conn.createStatement();
        ResultSet rs = st.executeQuery("SELECT DISTINCT class FROM students");
        while (rs.next()) {
            classes.add(rs.getString("class"));
        }
        conn.close();
    } catch (Exception e) {
        out.println("<div style='color:red;'>Error: " + e.getMessage() + "</div>");
    }

    // Fetch homework for selected class
    List<Map<String, Object>> homeworkList = new ArrayList<>();
    if (!selectedClass.isEmpty()) {
        try {
            Connection conn = util.DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM homework WHERE class=? ORDER BY due_date DESC");
            ps.setString(1, selectedClass);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> hw = new HashMap<>();
                hw.put("id", rs.getInt("id"));
                hw.put("subject", rs.getString("subject"));
                hw.put("description", rs.getString("description"));
                hw.put("due_date", rs.getDate("due_date"));
                homeworkList.add(hw);
            }
            conn.close();
        } catch (Exception e) {
            out.println("<div style='color:red;'>Error: " + e.getMessage() + "</div>");
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Homework</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .hw-table { margin: 0 auto; border-collapse: collapse; }
        .hw-table th, .hw-table td { border: 1px solid #ccc; padding: 8px 12px; }
    </style>
</head>
<body>
    <div class="header">
        <img src="images/<%= session.getAttribute("teacherPhoto") %>" alt="Teacher Photo" height="80">
        <span>Name: <%= session.getAttribute("teacherName") %></span>
        <span>Email: <%= session.getAttribute("teacherEmail") %></span>
    </div>
    <h2>Manage Homework</h2>
    <form method="get" style="margin-bottom:20px;">
        <label>Select Class:</label>
        <select name="class" onchange="this.form.submit()">
            <option value="">--Select--</option>
            <% for (String c : classes) { %>
                <option value="<%= c %>" <%= c.equals(selectedClass) ? "selected" : "" %>><%= c %></option>
            <% } %>
        </select>
    </form>
    <% if (!selectedClass.isEmpty()) { %>
        <h3>Add Homework</h3>
        <form action="AddHomeworkServlet" method="post">
            <input type="hidden" name="class" value="<%= selectedClass %>">
            <label>Subject:</label>
            <input type="text" name="subject" required>
            <label>Description:</label>
            <input type="text" name="description" required>
            <label>Due Date:</label>
            <input type="date" name="due_date" required>
            <button type="submit">Add</button>
        </form>
        <h3>Homework List</h3>
        <table class="hw-table">
            <tr>
                <th>Subject</th>
                <th>Description</th>
                <th>Due Date</th>
                <th>Action</th>
            </tr>
            <% for (Map<String, Object> hw : homeworkList) { %>
                <tr>
                    <td><%= hw.get("subject") %></td>
                    <td><%= hw.get("description") %></td>
                    <td><%= hw.get("due_date") %></td>
                    <td>
                        <form action="DeleteHomeworkServlet" method="post" style="display:inline;">
                            <input type="hidden" name="id" value="<%= hw.get("id") %>">
                            <button type="submit" onclick="return confirm('Delete this homework?')">Delete</button>
                        </form>
                    </td>
                </tr>
            <% } %>
        </table>
    <% } %>
    <a href="teacher_dashboard.jsp">Back to Dashboard</a>
</body>
</html>