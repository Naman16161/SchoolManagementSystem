package servlet;

import util.DBConnection;
import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class AddHomeworkServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String className = request.getParameter("class");
        String subject = request.getParameter("subject");
        String description = request.getParameter("description");
        String dueDate = request.getParameter("due_date");

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO homework (subject, description, due_date, class) VALUES (?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, subject);
            ps.setString(2, description);
            ps.setString(3, dueDate);
            ps.setString(4, className);
            ps.executeUpdate();
        } catch (Exception e) {
            throw new ServletException(e);
        }
        response.sendRedirect("manage_homework.jsp?class=" + className);
    }
}
