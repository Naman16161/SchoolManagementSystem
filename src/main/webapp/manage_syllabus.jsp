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
    String selectedSubject = request.getParameter("subject");

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

    // Fetch subjects for selected class
    List<String> subjects = new ArrayList<>();
    if (selectedClass != null && !selectedClass.isEmpty()) {
        try {
            Connection conn = util.DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement("SELECT DISTINCT subject FROM syllabus WHERE class=?");
            ps.setString(1, selectedClass);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                subjects.add(rs.getString("subject"));
            }
            conn.close();
        } catch (Exception e) {
            out.println("<div style='color:red;'>Error: " + e.getMessage() + "</div>");
        }
    }

    // Fetch syllabus for selected subject
    Map<String, String> ptSyllabus = new LinkedHashMap<>();
    if (selectedClass != null && !selectedClass.isEmpty() && selectedSubject != null && !selectedSubject.isEmpty()) {
        try {
            Connection conn = util.DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(
                "SELECT pt, syllabus_content FROM syllabus WHERE class=? AND subject=?");
            ps.setString(1, selectedClass);
            ps.setString(2, selectedSubject);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ptSyllabus.put(rs.getString("pt"), rs.getString("syllabus_content"));
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
    <title>Manage Syllabus</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .syllabus-section { margin: 20px auto; width: 60%; }
        .pt-title { font-weight: bold; margin-top: 15px; }
        .syllabus-content { margin-left: 20px; }
    </style>
</head>
<body>
    <div class="header">
        <img src="images/<%= session.getAttribute("teacherPhoto") %>" alt="Teacher Photo" height="80">
        <span>Name: <%= session.getAttribute("teacherName") %></span>
        <span>Email: <%= session.getAttribute("teacherEmail") %></span>
    </div>
    <h2>Manage Syllabus</h2>
    <form method="get" style="margin-bottom:20px;">
        <label>Select Class:</label>
        <select name="class" onchange="this.form.submit()">
            <option value="">--Select--</option>
            <% for (String c : classes) { %>
                <option value="<%= c %>" <%= c.equals(selectedClass) ? "selected" : "" %>><%= c %></option>
            <% } %>
        </select>
        <% if (selectedClass != null && !selectedClass.isEmpty()) { %>
            <label>Select Subject:</label>
            <select name="subject" onchange="this.form.submit()">
                <option value="">--Select--</option>
                <% for (String subj : subjects) { %>
                    <option value="<%= subj %>" <%= subj.equals(selectedSubject) ? "selected" : "" %>><%= subj %></option>
                <% } %>
            </select>
        <% } %>
    </form>
    <% if (selectedClass != null && !selectedClass.isEmpty() && selectedSubject != null && !selectedSubject.isEmpty()) { %>
        <form action="UpdateSyllabusServlet" method="post">
            <input type="hidden" name="class" value="<%= selectedClass %>">
            <input type="hidden" name="subject" value="<%= selectedSubject %>">
            <% for (String pt : Arrays.asList("PT1", "PT2", "PT3", "PT4")) { %>
                <div class="pt-title"><%= pt %> Syllabus:</div>
                <textarea name="syllabus_<%= pt %>" rows="3" cols="80"><%= ptSyllabus.getOrDefault(pt, "") %></textarea>
            <% } %>
            <br>
            <button type="submit" style="margin-top:15px;">Save Syllabus</button>
        </form>
    <% } %>
    <a href="teacher_dashboard.jsp">Back to Dashboard</a>
</body>
</html>