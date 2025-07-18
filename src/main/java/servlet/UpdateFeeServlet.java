package servlet;

import util.DBConnection;
import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class UpdateFeeServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int studentId = Integer.parseInt(request.getParameter("studentId"));
        double totalFee = Double.parseDouble(request.getParameter("total_fee"));
        double feePaid = Double.parseDouble(request.getParameter("fee_paid"));
        double lateFee = Double.parseDouble(request.getParameter("late_fee"));
        double admissionFee = Double.parseDouble(request.getParameter("admission_fee"));

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "UPDATE fees SET total_fee=?, fee_paid=?, late_fee=?, admission_fee=? WHERE student_id=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setDouble(1, totalFee);
            ps.setDouble(2, feePaid);
            ps.setDouble(3, lateFee);
            ps.setDouble(4, admissionFee);
            ps.setInt(5, studentId);
            int rows = ps.executeUpdate();
            // If no row exists, insert
            if (rows == 0) {
                sql = "INSERT INTO fees (student_id, total_fee, fee_paid, late_fee, admission_fee) VALUES (?, ?, ?, ?, ?)";
                ps = conn.prepareStatement(sql);
                ps.setInt(1, studentId);
                ps.setDouble(2, totalFee);
                ps.setDouble(3, feePaid);
                ps.setDouble(4, lateFee);
                ps.setDouble(5, admissionFee);
                ps.executeUpdate();
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
        response.sendRedirect("manage_fee.jsp?class=&studentId=" + studentId);
    }
}
