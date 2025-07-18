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
    String selectedDate = request.getParameter("date");
    if (selectedDate == null || selectedDate.isEmpty()) {
        selectedDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
    }

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

    // Fetch students for selected class
    List<Map<String, Object>> students = new ArrayList<>();
    if (selectedClass != null && !selectedClass.isEmpty()) {
        try {
            Connection conn = util.DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement("SELECT id, name, roll_no FROM students WHERE class=?");
            ps.setString(1, selectedClass);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> stu = new HashMap<>();
                stu.put("id", rs.getInt("id"));
                stu.put("name", rs.getString("name"));
                stu.put("roll_no", rs.getString("roll_no"));
                students.add(stu);
            }
            conn.close();
        } catch (Exception e) {
            out.println("<div style='color:red;'>Error: " + e.getMessage() + "</div>");
        }
    }

    // Fetch attendance for selected date
    Map<Integer, String> attendanceMap = new HashMap<>();
    if (selectedClass != null && !selectedClass.isEmpty() && selectedDate != null) {
        try {
            Connection conn = util.DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(
                "SELECT student_id, status FROM attendance WHERE date=? AND student_id IN (SELECT id FROM students WHERE class=?)");
            ps.setString(1, selectedDate);
            ps.setString(2, selectedClass);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                attendanceMap.put(rs.getInt("student_id"), rs.getString("status"));
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
    <title>Manage Attendance</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .att-table { margin: 0 auto; border-collapse: collapse; }
        .att-table th, .att-table td { border: 1px solid #ccc; padding: 8px 12px; }
    </style>
</head>
<body>
    <div class="header">
        <img src="images/<%= session.getAttribute("teacherPhoto") %>" alt="Teacher Photo" height="80">
        <span>Name: <%= session.getAttribute("teacherName") %></span>
        <span>Email: <%= session.getAttribute("teacherEmail") %></span>
    </div>
    <h2>Manage Attendance</h2>
    <form method="get" style="margin-bottom:20px;">
        <label>Select Class:</label>
        <select name="class" onchange="this.form.submit()">
            <option value="">--Select--</option>
            <% for (String c : classes) { %>
                <option value="<%= c %>" <%= c.equals(selectedClass) ? "selected" : "" %>><%= c %></option>
            <% } %>
        </select>
        <% if (selectedClass != null && !selectedClass.isEmpty()) { %>
            <label>Date:</label>
            <input type="date" name="date" value="<%= selectedDate %>" onchange="this.form.submit()">
        <% } %>
    </form>
    <% if (selectedClass != null && !selectedClass.isEmpty() && students.size() > 0) { %>
        <form action="UpdateAttendanceServlet" method="post">
            <input type="hidden" name="class" value="<%= selectedClass %>">
            <input type="hidden" name="date" value="<%= selectedDate %>">
            <table class="att-table">
                <tr>
                    <th>Roll No</th>
                    <th>Name</th>
                    <th>Status</th>
                </tr>
                <% for (Map<String, Object> stu : students) { 
                    int stuId = (Integer)stu.get("id");
                    String status = attendanceMap.getOrDefault(stuId, "Absent");
                %>
                    <tr>
                        <td><%= stu.get("roll_no") %></td>
                        <td><%= stu.get("name") %></td>
                        <td>
                            <select name="status_<%= stuId %>">
                                <option value="Present" <%= "Present".equals(status) ? "selected" : "" %>>Present</option>
                                <option value="Absent" <%= "Absent".equals(status) ? "selected" : "" %>>Absent</option>
                            </select>
                        </td>
                    </tr>
                <% } %>
            </table>
            <button type="submit" style="margin-top:15px;">Save Attendance</button>
        </form>
    <% } %>
    <a href="teacher_dashboard.jsp">Back to Dashboard</a>
</body>
</html>