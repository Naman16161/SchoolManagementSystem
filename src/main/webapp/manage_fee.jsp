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
    String selectedStudentId = request.getParameter("studentId");

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

    // Fetch fee details for selected student
    double totalFee = 0, feePaid = 0, lateFee = 0, admissionFee = 0;
    List<Map<String, Object>> receipts = new ArrayList<>();
    if (selectedStudentId != null && !selectedStudentId.isEmpty()) {
        try {
            Connection conn = util.DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM fees WHERE student_id=?");
            ps.setInt(1, Integer.parseInt(selectedStudentId));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                totalFee = rs.getDouble("total_fee");
                feePaid = rs.getDouble("fee_paid");
                lateFee = rs.getDouble("late_fee");
                admissionFee = rs.getDouble("admission_fee");
            }
            // Get receipts
            PreparedStatement ps2 = conn.prepareStatement("SELECT * FROM fee_receipts WHERE student_id=?");
            ps2.setInt(1, Integer.parseInt(selectedStudentId));
            ResultSet rs2 = ps2.executeQuery();
            while (rs2.next()) {
                Map<String, Object> rec = new HashMap<>();
                rec.put("amount", rs2.getDouble("amount"));
                rec.put("payment_date", rs2.getDate("payment_date"));
                rec.put("receipt_url", rs2.getString("receipt_url"));
                receipts.add(rec);
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
    <title>Manage Fee</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .fee-table { margin: 0 auto; border-collapse: collapse; }
        .fee-table th, .fee-table td { border: 1px solid #ccc; padding: 8px 12px; }
    </style>
</head>
<body>
    <div class="header">
        <img src="images/<%= session.getAttribute("teacherPhoto") %>" alt="Teacher Photo" height="80">
        <span>Name: <%= session.getAttribute("teacherName") %></span>
        <span>Email: <%= session.getAttribute("teacherEmail") %></span>
    </div>
    <h2>Manage Fee</h2>
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
    </form>
    <% if (selectedStudentId != null && !selectedStudentId.isEmpty()) { %>
        <h3>Fee Details</h3>
        <form action="UpdateFeeServlet" method="post">
            <input type="hidden" name="studentId" value="<%= selectedStudentId %>">
            <label>Total Fee:</label>
            <input type="number" name="total_fee" value="<%= totalFee %>" step="0.01" required>
            <label>Fee Paid:</label>
            <input type="number" name="fee_paid" value="<%= feePaid %>" step="0.01" required>
            <label>Late Fee:</label>
            <input type="number" name="late_fee" value="<%= lateFee %>" step="0.01" required>
            <label>Admission Fee:</label>
            <input type="number" name="admission_fee" value="<%= admissionFee %>" step="0.01" required>
            <button type="submit">Update</button>
        </form>
        <h3>Add Fee Receipt</h3>
        <form action="AddFeeReceiptServlet" method="post">
            <input type="hidden" name="studentId" value="<%= selectedStudentId %>">
            <label>Amount:</label>
            <input type="number" name="amount" step="0.01" required>
            <label>Payment Date:</label>
            <input type="date" name="payment_date" required>
            <label>Receipt URL:</label>
            <input type="text" name="receipt_url">
            <button type="submit">Add Receipt</button>
        </form>
        <h3>Receipts</h3>
        <table class="fee-table">
            <tr>
                <th>Amount</th>
                <th>Date</th>
                <th>Receipt</th>
            </tr>
            <% for (Map<String, Object> rec : receipts) { %>
                <tr>
                    <td>₹<%= rec.get("amount") %></td>
                    <td><%= rec.get("payment_date") %></td>
                    <td>
                        <% if (rec.get("receipt_url") != null) { %>
                            <a href="<%= rec.get("receipt_url") %>" target="_blank">View</a>
                        <% } else { %>
                            N/A
                        <% } %>
                    </td>
                </tr>
            <% } %>
        </table>
    <% } %>
    <a href="teacher_dashboard.jsp">Back to Dashboard</a>
</body>
</html>