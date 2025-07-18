<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String className = (String) session.getAttribute("className");
    String selectedSubject = request.getParameter("subject");

    // Fetch subjects for this class
    List<String> subjects = new ArrayList<>();
    try {
        Connection conn = util.DBConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT DISTINCT subject FROM syllabus WHERE class=?");
        ps.setString(1, className);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            subjects.add(rs.getString("subject"));
        }
        conn.close();
    } catch (Exception e) {
        out.println("<div style='color:red;'>Error: " + e.getMessage() + "</div>");
    }

    // Fetch syllabus for selected subject
    Map<String, String> ptSyllabus = new LinkedHashMap<>();
    if (selectedSubject != null && !selectedSubject.isEmpty()) {
        try {
            Connection conn = util.DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(
                "SELECT pt, syllabus_content FROM syllabus WHERE class=? AND subject=? ORDER BY pt");
            ps.setString(1, className);
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
    <title>Syllabus</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .syllabus-section { margin: 20px auto; width: 60%; }
        .pt-title { font-weight: bold; margin-top: 15px; }
        .syllabus-content { margin-left: 20px; }
    </style>
</head>
<body>
    <div class="header">
        <img src="images/<%= session.getAttribute("photo") %>" alt="Student Photo" height="80">
        <span>Name: <%= session.getAttribute("name") %></span>
        <span>Class: <%= session.getAttribute("className") %></span>
        <span>Roll No: <%= session.getAttribute("roll_no") %></span>
    </div>
    <h2>Syllabus</h2>
    <form method="get" style="margin-bottom:20px;">
        <label>Select Subject:</label>
        <select name="subject" onchange="this.form.submit()">
            <option value="">--Select--</option>
            <% for (String subj : subjects) { %>
                <option value="<%= subj %>" <%= subj.equals(selectedSubject) ? "selected" : "" %>><%= subj %></option>
            <% } %>
        </select>
    </form>
    <% if (selectedSubject != null && !selectedSubject.isEmpty()) { %>
        <div class="syllabus-section">
            <% for (String pt : Arrays.asList("PT1", "PT2", "PT3", "PT4")) { %>
                <div class="pt-title"><%= pt %> Syllabus:</div>
                <div class="syllabus-content">
                    <%= ptSyllabus.getOrDefault(pt, "Not available") %>
                </div>
            <% } %>
        </div>
    <% } else { %>
        <p>Please select a subject to view the syllabus.</p>
    <% } %>
    <a href="dashboard.jsp">Back to Dashboard</a>
</body>
</html>