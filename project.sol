    // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AdaptiveCurriculum {
    
    struct Course {
        uint256 id;
        string name;
        string description;
        uint256 duration; // duration in days
        bool isCompleted;
    }

    struct Student {
        uint256 id;
        string name;
        uint256[] enrolledCourses; // Store list of course IDs the student is enrolled in
        mapping(uint256 => bool) completedCourses; // Track which courses a student has completed
    }

    address public admin;
    uint256 public nextStudentId;
    uint256 public nextCourseId;
    
    mapping(uint256 => Course) public courses;
    mapping(uint256 => Student) public students;

    event StudentEnrolled(uint256 studentId, string studentName);
    event CourseAdded(uint256 courseId, string courseName);
    event CourseCompleted(uint256 studentId, uint256 courseId);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier courseExists(uint256 courseId) {
        require(courseId < nextCourseId, "Course does not exist");
        _;
    }

    modifier studentExists(uint256 studentId) {
        require(studentId < nextStudentId, "Student does not exist");
        _;
    }

    constructor() {
        admin = msg.sender;
        nextStudentId = 0;
        nextCourseId = 0;
    }

    // Function to add a new course to the curriculum
    function addCourse(string memory name, string memory description, uint256 duration) public onlyAdmin {
        courses[nextCourseId] = Course({
            id: nextCourseId,
            name: name,
            description: description,
            duration: duration,
            isCompleted: false
        });
        emit CourseAdded(nextCourseId, name);
        nextCourseId++;
    }

    // Function for students to enroll
    function enrollStudent(string memory name) public {
        students[nextStudentId].id = nextStudentId;
        students[nextStudentId].name = name;
        emit StudentEnrolled(nextStudentId, name);
        nextStudentId++;
    }

    // Function for a student to enroll in a course
    function enrollInCourse(uint256 studentId, uint256 courseId) public studentExists(studentId) courseExists(courseId) {
        Student storage student = students[studentId];
        student.enrolledCourses.push(courseId);
    }

    // Function to mark a course as completed by a student
    function completeCourse(uint256 studentId, uint256 courseId) public studentExists(studentId) courseExists(courseId) {
        Student storage student = students[studentId];
        require(!student.completedCourses[courseId], "Course already completed");
        student.completedCourses[courseId] = true;
        emit CourseCompleted(studentId, courseId);
    }

    // Function to get details of a course
    function getCourseDetails(uint256 courseId) public view returns (string memory, string memory, uint256, bool) {
        Course memory course = courses[courseId];
        return (course.name, course.description, course.duration, course.isCompleted);
    }

    // Function to get details of a student
    function getStudentDetails(uint256 studentId) public view returns (string memory, uint256[] memory, bool[] memory) {
        Student storage student = students[studentId];
        uint256 courseCount = student.enrolledCourses.length;
        bool[] memory completed = new bool[](courseCount);

        for (uint256 i = 0; i < courseCount; i++) {
            completed[i] = student.completedCourses[student.enrolledCourses[i]];
        }

        return (student.name, student.enrolledCourses, completed);
    }
}

