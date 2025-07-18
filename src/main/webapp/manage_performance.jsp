<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.util.Arrays" %>
<%@ page session="true" %>
<%
    response.setContentType("text/html;charset=UTF-8");

    if (session.getAttribute("teacherId") == null) {
        response.sendRedirect("teacher_login.jsp");
        return;
    }

    String selectedClass = request.getParameter("class");
    String selectedStudentId = request.getParameter("studentId");
    String selectedTest = request.getParameter("test_name");

    // Fetch all classes for dropdown
    List<String> classes = new ArrayList<>();
    try (Connection conn = util.DBConnection.getConnection();
         Statement st = conn.createStatement();
         ResultSet rs = st.executeQuery("SELECT DISTINCT class FROM students")) {
        while (rs.next()) {
            classes.add(rs.getString("class"));
        }
    } catch (Exception e) {
        out.println("<div class='error-msg'>Error: " + e.getMessage() + "</div>");
    }

    // Fetch students for selected class
    List<Map<String, Object>> students = new ArrayList<>();
    if (selectedClass != null && !selectedClass.isEmpty()) {
        try (Connection conn = util.DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT id, name, roll_no FROM students WHERE class=?")) {
            ps.setString(1, selectedClass);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> stu = new HashMap<>();
                    stu.put("id", rs.getInt("id"));
                    stu.put("name", rs.getString("name"));
                    stu.put("roll_no", rs.getString("roll_no"));
                    students.add(stu);
                }
            }
        } catch (Exception e) {
            out.println("<div class='error-msg'>Error: " + e.getMessage() + "</div>");
        }
    }

    // Fetch subjects for the class (from syllabus table)
    List<String> subjects = new ArrayList<>();
    if (selectedClass != null && !selectedClass.isEmpty()) {
        try (Connection conn = util.DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT DISTINCT subject FROM syllabus WHERE class=?")) {
            ps.setString(1, selectedClass);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    subjects.add(rs.getString("subject"));
                }
            }
        } catch (Exception e) {
            out.println("<div class='error-msg'>Error: " + e.getMessage() + "</div>");
        }
    }

    // Fetch performance for selected student and test
    Map<String, Map<String, Object>> perfMap = new HashMap<>();
    String remark = "";
    if (selectedStudentId != null && !selectedStudentId.isEmpty() && selectedTest != null && !selectedTest.isEmpty()) {
        try (Connection conn = util.DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT subject, marks_obtained, total_marks FROM performance WHERE student_id=? AND test_name=?");
            ps.setInt(1, Integer.parseInt(selectedStudentId));
            ps.setString(2, selectedTest);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("marks_obtained", rs.getDouble("marks_obtained"));
                    row.put("total_marks", rs.getDouble("total_marks"));
                    perfMap.put(rs.getString("subject"), row);
                }
            }

            // Get teacher remark
            PreparedStatement ps2 = conn.prepareStatement(
                "SELECT remark FROM teacher_remarks WHERE student_id=? AND test_name=?");
            ps2.setInt(1, Integer.parseInt(selectedStudentId));
            ps2.setString(2, selectedTest);
            try (ResultSet rs2 = ps2.executeQuery()) {
                if (rs2.next()) {
                    remark = rs2.getString("remark");
                }
            }
        } catch (Exception e) {
            out.println("<div class='error-msg'>Error: " + e.getMessage() + "</div>");
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Performance</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .perf-table { margin: 0 auto; border-collapse: collapse; }
        .perf-table th, .perf-table td { border: 1px solid #ccc; padding: 8px 12px; }
        .header { padding: 10px; background: #f2f2f2; }
        .header img { vertical-align: middle; margin-right: 10px; }
        .error-msg { color: red; font-weight: bold; margin: 10px; }
    </style>
</head>
<body>
    <div class="header">
        <img src="images/<%= session.getAttribute("teacherPhoto") %>" alt="Teacher Photo" height="80">
        <span>Name: <%= session.getAttribute("teacherName") %></span><br>
        <span>Email: <%= session.getAttribute("teacherEmail") %></span>
    </div>
    <h2>Manage Performance</h2>

    <form method="get" style="margin-bottom:20px;">
        <label>Select Class:</label>
        <select name="class" onchange="this.form.submit()">
            <option value="">--Select--</option>
            <% for (String c : classes) { %>
                <option value="<%= c %>" <%= c.equals(selectedClass) ? "selected" : "" %>><%= c %></option>
            <% } %>
        </select>

        <% if (selectedClass != null && !selectedClass.isEmpty()) { %>
            <label>Select Student:</label>
            <select name="studentId" onchange="this.form.submit()">
                <option value="">--Select--</option>
                <% for (Map<String, Object> stu : students) { %>
                    <option value="<%= stu.get("id") %>" <%= (""+stu.get("id")).equals(selectedStudentId) ? "selected" : "" %>>
                        <%= stu.get("name") %> (Roll: <%= stu.get("roll_no") %>)
                    </option>
                <% } %>
            </select>
        <% } %>

        <% if (selectedStudentId != null && !selectedStudentId.isEmpty()) { %>
            <label>Test Name:</label>
            <select name="test_name" onchange="this.form.submit()">
                <option value="">--Select--</option>
                <% for (String t : Arrays.asList("PT1", "PT2", "PT3", "PT4", "Half-Yearly", "Final")) { %>
                    <option value="<%= t %>" <%= t.equals(selectedTest) ? "selected" : "" %>><%= t %></option>
                <% } %>
            </select>
        <% } %>
    </form>

    <% if (selectedStudentId != null && !selectedStudentId.isEmpty() && selectedTest != null && !selectedTest.isEmpty()) { %>
        <form action="UpdatePerformanceServlet" method="post">
            <input type="hidden" name="studentId" value="<%= selectedStudentId %>">
            <input type="hidden" name="test_name" value="<%= selectedTest %>">
            <table class="perf-table">
                <tr>
                    <th>Subject</th>
                    <th>Marks Obtained</th>
                    <th>Total Marks</th>
                </tr>
                <% for (String subj : subjects) {
                    Map<String, Object> row = perfMap.getOrDefault(subj, new HashMap<>());
                    double marks = row.get("marks_obtained") != null ? (Double)row.get("marks_obtained") : 0;
                    double total = row.get("total_marks") != null ? (Double)row.get("total_marks") : 100;
                %>
                    <tr>
                        <td><%= subj %></td>
                        <td>
                            <input type="number" name="marks_<%= subj %>" value="<%= marks %>" step="0.01" required>
                        </td>
                        <td>
                            <input type="number" name="total_<%= subj %>" value="<%= total %>" step="0.01" required>
                        </td>
                    </tr>
                <% } %>
            </table>
            <label>Teacher's Remark:</label>
            <input type="text" name="remark" value="<%= remark %>" style="width:300px;">
            <br>
            <button type="submit" style="margin-top:15px;">Save Performance</button>
        </form>
    <% } %>

    <br>
    <a href="teacher_dashboard.jsp">Back to Dashboard</a>
</body>
</html>
