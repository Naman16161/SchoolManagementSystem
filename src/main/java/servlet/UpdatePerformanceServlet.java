package servlet;

import util.DBConnection;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class UpdatePerformanceServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int studentId = Integer.parseInt(request.getParameter("studentId"));
        String testName = request.getParameter("test_name");
        String remark = request.getParameter("remark");

        // Get all subjects from syllabus for the student's class
        List<String> subjects = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT DISTINCT subject FROM syllabus WHERE class=(SELECT class FROM students WHERE id=?)");
            ps.setInt(1, studentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                subjects.add(rs.getString("subject"));
            }

            // For each subject, update or insert performance
            for (String subj : subjects) {
                double marks = Double.parseDouble(request.getParameter("marks_" + subj));
                double total = Double.parseDouble(request.getParameter("total_" + subj));
                // Check if record exists
                PreparedStatement check = conn.prepareStatement(
                    "SELECT id FROM performance WHERE student_id=? AND test_name=? AND subject=?");
                check.setInt(1, studentId);
                check.setString(2, testName);
                check.setString(3, subj);
                ResultSet rsCheck = check.executeQuery();
                if (rsCheck.next()) {
                    // Update
                    PreparedStatement update = conn.prepareStatement(
                        "UPDATE performance SET marks_obtained=?, total_marks=? WHERE student_id=? AND test_name=? AND subject=?");
                    update.setDouble(1, marks);
                    update.setDouble(2, total);
                    update.setInt(3, studentId);
                    update.setString(4, testName);
                    update.setString(5, subj);
                    update.executeUpdate();
                } else {
                    // Insert
                    PreparedStatement insert = conn.prepareStatement(
                        "INSERT INTO performance (student_id, test_name, subject, marks_obtained, total_marks) VALUES (?, ?, ?, ?, ?)");
                    insert.setInt(1, studentId);
                    insert.setString(2, testName);
                    insert.setString(3, subj);
                    insert.setDouble(4, marks);
                    insert.setDouble(5, total);
                    insert.executeUpdate();
                }
            }

            // Update or insert teacher remark
            PreparedStatement checkRemark = conn.prepareStatement(
                "SELECT id FROM teacher_remarks WHERE student_id=? AND test_name=?");
            checkRemark.setInt(1, studentId);
            checkRemark.setString(2, testName);
            ResultSet rsRemark = checkRemark.executeQuery();
            if (rsRemark.next()) {
                PreparedStatement update = conn.prepareStatement(
                    "UPDATE teacher_remarks SET remark=? WHERE student_id=? AND test_name=?");
                update.setString(1, remark);
                update.setInt(2, studentId);
                update.setString(3, testName);
                update.executeUpdate();
            } else {
                PreparedStatement insert = conn.prepareStatement(
                    "INSERT INTO teacher_remarks (student_id, test_name, remark) VALUES (?, ?, ?)");
                insert.setInt(1, studentId);
                insert.setString(2, testName);
                insert.setString(3, remark);
                insert.executeUpdate();
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
        response.sendRedirect("manage_performance.jsp?class=&studentId=" + studentId + "&test_name=" + testName);
    }
}
