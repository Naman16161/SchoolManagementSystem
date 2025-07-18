<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    <%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ page session="true" %>
<%
    Integer studentId = (Integer) session.getAttribute("studentId");
    String className = (String) session.getAttribute("className");
    String selectedSubject = request.getParameter("subject");
    String view = request.getParameter("view");
    if (view == null) view = "today";

    List<String> subjects = new ArrayList<>();
    List<Map<String, Object>> homeworkList = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = util.DBConnection.getConnection();

        // Get all subjects for filter
        PreparedStatement psSub = conn.prepareStatement("SELECT DISTINCT subject FROM homework WHERE class=?");
        psSub.setString(1, className);
        ResultSet rsSub = psSub.executeQuery();
        while (rsSub.next()) {
            subjects.add(rsSub.getString("subject"));
        }

        // Build query for homework
        String sql = "SELECT h.*, IFNULL(hc.completed, 0) AS completed FROM homework h " +
                     "LEFT JOIN homework_completion hc ON h.id=hc.homework_id AND hc.student_id=? " +
                     "WHERE h.class=? ";
        if (selectedSubject != null && !selectedSubject.isEmpty()) {
            sql += "AND h.subject=? ";
        }
        if ("today".equals(view)) {
            sql += "AND h.due_date=CURDATE() ";
        } else {
            sql += "AND h.due_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 6 DAY) ";
        }
        sql += "ORDER BY h.due_date ASC";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, studentId);
        ps.setString(2, className);
        int paramIndex = 3;
        if (selectedSubject != null && !selectedSubject.isEmpty()) {
            ps.setString(paramIndex++, selectedSubject);
        }
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, Object> hw = new HashMap<>();
            hw.put("id", rs.getInt("id"));
            hw.put("subject", rs.getString("subject"));
            hw.put("description", rs.getString("description"));
            hw.put("due_date", rs.getDate("due_date"));
            hw.put("completed", rs.getBoolean("completed"));
            homeworkList.add(hw);
        }
        conn.close();
    } catch (Exception e) {
        out.println("<div style='color:red;'>Error: " + e.getMessage() + "</div>");
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Homework</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="header">
        <img src="images/<%= session.getAttribute("photo") %>" alt="Student Photo" height="80">
        <span>Name: <%= session.getAttribute("name") %></span>
        <span>Class: <%= session.getAttribute("className") %></span>
        <span>Roll No: <%= session.getAttribute("roll_no") %></span>
    </div>
    <h2>Homework</h2>
    <form method="get" style="margin-bottom:20px;">
        <label>View:</label>
        <select name="view" onchange="this.form.submit()">
            <option value="today" <%= "today".equals(view) ? "selected" : "" %>>Today's Homework</option>
            <option value="week" <%= "week".equals(view) ? "selected" : "" %>>This Week</option>
        </select>
        <label>Subject:</label>
        <select name="subject" onchange="this.form.submit()">
            <option value="">All</option>
            <% for (String subj : subjects) { %>
                <option value="<%= subj %>" <%= subj.equals(selectedSubject) ? "selected" : "" %>><%= subj %></option>
            <% } %>
        </select>
    </form>
    <ul>
        <% for (Map<String, Object> hw : homeworkList) { %>
            <li>
                <b><%= hw.get("subject") %></b> - <%= hw.get("description") %> (Due: <%= hw.get("due_date") %>)
                <% if ((Boolean)hw.get("completed")) { %>
                    <span style="color:green;">[Completed]</span>
                <% } else { %>
                    <form action="MarkHomeworkServlet" method="post" style="display:inline;">
                        <input type="hidden" name="homeworkId" value="<%= hw.get("id") %>">
                        <button type="submit">Mark as Completed</button>
                    </form>
                <% } %>
            </li>
        <% } %>
    </ul>
    <a href="dashboard.jsp">Back to Dashboard</a>
</body>
</html>
<%
%>