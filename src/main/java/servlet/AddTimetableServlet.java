package servlet;

import util.DBConnection;
import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class AddTimetableServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String className = request.getParameter("class");
        String day = request.getParameter("day");
        String startTime = request.getParameter("start_time");
        String endTime = request.getParameter("end_time");
        String type = request.getParameter("type");
        String subject = request.getParameter("subject");
        String breakType = request.getParameter("break_type");

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO timetable (class, day, start_time, end_time, subject, is_break, break_type) VALUES (?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, className);
            ps.setString(2, day);
            ps.setString(3, startTime);
            ps.setString(4, endTime);
            if ("period".equals(type)) {
                ps.setString(5, subject);
                ps.setBoolean(6, false);
                ps.setNull(7, java.sql.Types.VARCHAR);
            } else {
                ps.setNull(5, java.sql.Types.VARCHAR);
                ps.setBoolean(6, true);
                ps.setString(7, breakType);
            }
            ps.executeUpdate();
        } catch (Exception e) {
            throw new ServletException(e);
        }
        response.sendRedirect("manage_timetable.jsp?class=" + className + "&day=" + day);
    }
}
