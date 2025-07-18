<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    Integer studentId = (Integer) session.getAttribute("studentId");
    String tab = request.getParameter("tab");
    if (tab == null) tab = "total";

    double totalFee = 0, feePaid = 0, lateFee = 0, admissionFee = 0;
    List<Map<String, Object>> receipts = new ArrayList<>();

    try {
        Connection conn = util.DBConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM fees WHERE student_id=?");
        ps.setInt(1, studentId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            totalFee = rs.getDouble("total_fee");
            feePaid = rs.getDouble("fee_paid");
            lateFee = rs.getDouble("late_fee");
            admissionFee = rs.getDouble("admission_fee");
        }

        // Get receipts
        PreparedStatement ps2 = conn.prepareStatement("SELECT * FROM fee_receipts WHERE student_id=?");
        ps2.setInt(1, studentId);
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
    double remainingFee = totalFee - feePaid;
%>
<!DOCTYPE html>
<html>
<head>
    <title>Fee Details</title>
    <link rel="stylesheet" href="style.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .tabs { display: flex; gap: 10px; margin-bottom: 20px; }
        .tab { padding: 10px 20px; background: #eee; border-radius: 5px; cursor: pointer; text-decoration: none; color: black; }
        .tab.active { background: #0074d9; color: #fff; }
        .tab-content { margin-bottom: 30px; }
        .receipts-table { margin: 0 auto; border-collapse: collapse; }
        .receipts-table th, .receipts-table td { border: 1px solid #ccc; padding: 8px 12px; }
        .header span { display: block; margin: 5px 0; }
    </style>
</head>
<body>
    <div class="header">
        <img src="images/<%= session.getAttribute("photo") %>" alt="Student Photo" height="80">
        <span>Name: <%= session.getAttribute("name") %></span>
        <span>Class: <%= session.getAttribute("className") %></span>
        <span>Roll No: <%= session.getAttribute("roll_no") %></span>
    </div>

    <h2>Fee Details</h2>
    <div class="tabs">
        <a href="fee.jsp?tab=total" class="tab <%= "total".equals(tab) ? "active" : "" %>">Total Fee</a>
        <a href="fee.jsp?tab=paid" class="tab <%= "paid".equals(tab) ? "active" : "" %>">Fee Paid</a>
        <a href="fee.jsp?tab=late" class="tab <%= "late".equals(tab) ? "active" : "" %>">Late Fee</a>
        <a href="fee.jsp?tab=admission" class="tab <%= "admission".equals(tab) ? "active" : "" %>">Admission Fee</a>
    </div>

    <div class="tab-content">
        <% if ("total".equals(tab)) { %>
            <h3>Total Fee: ₹<%= String.format("%.2f", totalFee) %></h3>
            <h4>Remaining Fee: ₹<%= String.format("%.2f", remainingFee) %></h4>
        <% } else if ("paid".equals(tab)) { %>
            <h3>Fee Paid: ₹<%= String.format("%.2f", feePaid) %></h3>
            <h4>Receipts:</h4>
            <table class="receipts-table">
                <tr><th>Amount</th><th>Date</th><th>Receipt</th></tr>
                <% for (Map<String, Object> rec : receipts) { %>
                    <tr>
                        <td>₹<%= String.format("%.2f", rec.get("amount")) %></td>
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
        <% } else if ("late".equals(tab)) { %>
            <h3>Late Fee: ₹<%= String.format("%.2f", lateFee) %></h3>
        <% } else if ("admission".equals(tab)) { %>
            <h3>Admission Fee: ₹<%= String.format("%.2f", admissionFee) %></h3>
        <% } %>
    </div>
     <a href="dashboard.jsp">Back to Dashboard</a>
</body>
</html>
