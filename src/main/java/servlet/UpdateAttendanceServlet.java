package servlet;

import util.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class UpdateAttendanceServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String className = request.getParameter("class");
        String date = request.getParameter("date");

        // Get all students in the class
        List<Integer> studentIds = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement("SELECT id FROM students WHERE class=?");
            ps.setString(1, className);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                studentIds.add(rs.getInt("id"));
            }

            // For each student, update or insert attendance
            for (int stuId : studentIds) {
                String status = request.getParameter("status_" + stuId);
                // Check if record exists
                PreparedStatement check = conn.prepareStatement("SELECT id FROM attendance WHERE student_id=? AND date=?");
                check.setInt(1, stuId);
                check.setString(2, date);
                ResultSet rsCheck = check.executeQuery();
                if (rsCheck.next()) {
                    // Update
                    PreparedStatement update = conn.prepareStatement("UPDATE attendance SET status=? WHERE student_id=? AND date=?");
                    update.setString(1, status);
                    update.setInt(2, stuId);
                    update.setString(3, date);
                    update.executeUpdate();
                } else {
                    // Insert
                    PreparedStatement insert = conn.prepareStatement("INSERT INTO attendance (student_id, date, status) VALUES (?, ?, ?)");
                    insert.setInt(1, stuId);
                    insert.setString(2, date);
                    insert.setString(3, status);
                    insert.executeUpdate();
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
        response.sendRedirect("manage_attendance.jsp?class=" + className + "&date=" + date);
    }
}
