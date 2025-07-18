package servlet;

import util.DBConnection;
import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class AddFeeReceiptServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int studentId = Integer.parseInt(request.getParameter("studentId"));
        double amount = Double.parseDouble(request.getParameter("amount"));
        String paymentDate = request.getParameter("payment_date");
        String receiptUrl = request.getParameter("receipt_url");

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO fee_receipts (student_id, amount, payment_date, receipt_url) VALUES (?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, studentId);
            ps.setDouble(2, amount);
            ps.setString(3, paymentDate);
            ps.setString(4, receiptUrl);
            ps.executeUpdate();
        } catch (Exception e) {
            throw new ServletException(e);
        }
        response.sendRedirect("manage_fee.jsp?class=&studentId=" + studentId);
    }
}