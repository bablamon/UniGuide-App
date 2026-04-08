-- ============================================================================
-- Wiki Articles Seed (004)
--
-- Sourced from pccoepune.com — accurate stats, real rankings, actual numbers.
-- 20 articles across: general, facilities, hostel, placements, events, clubs, exams.
--
-- Clears all existing articles before inserting. Safe to re-run.
-- Run in Supabase SQL Editor.
-- ============================================================================

DELETE FROM public.wiki_articles;

INSERT INTO public.wiki_articles
  (id, title, summary, body, category, target_years, target_branches, is_pinned, status, updated_at, last_verified_at)
VALUES

-- ── 1. About PCCOE (PINNED) ─────────────────────────────────────────────────
(
  'a1000000-0000-0000-0000-000000000001',
  'About PCCOE',
  'NAAC ''A'' Grade (3.20), NBA Accredited, Autonomous Institute — established 1999, affiliated to SPPU, ISO 21001:2018 certified, ranked among top engineering colleges in India.',
  $body$<h2>Pimpri Chinchwad College of Engineering (PCCOE)</h2>
<p>PCCOE is a premier autonomous engineering institution located in <strong>Sector 26, Pradhikaran, Nigdi, Pune 411044</strong>, near Akurdi Railway Station. Established in <strong>1999</strong> and managed by the <strong>Pimpri Chinchwad Education Trust (PCET)</strong>.</p>
<h3>Accreditations &amp; Recognition</h3>
<ul>
  <li><strong>NAAC Accredited — 'A' Grade</strong> (Score: 3.20)</li>
  <li><strong>NBA Accredited</strong> — multiple programs including all 4 PG programs (3-year accreditation through 2028)</li>
  <li><strong>Autonomous Institute</strong> under Savitribai Phule Pune University (SPPU)</li>
  <li><strong>AICTE Approved</strong></li>
  <li><strong>ISO 21001:2018</strong> and <strong>ISO 9001:2015</strong> Certified</li>
  <li>Recognised under UGC schemes 2(f) and 12(B)</li>
</ul>
<h3>National Rankings (2024–25)</h3>
<ul>
  <li><strong>India Today</strong>: 58th among private engineering colleges</li>
  <li><strong>Outlook iCARE</strong>: 37th among top 200 private engineering institutes</li>
  <li><strong>DataQuest T-School</strong>: 6th in West Zone, 29th nationally (private)</li>
  <li><strong>The Week–Hansa Research</strong>: 11th in West Zone, 68th nationally</li>
  <li><strong>Times All India Engineering Survey</strong>: 14th among top 175 institutes</li>
  <li><strong>Silicon India</strong>: 22nd nationally, 5th in West India</li>
</ul>
<h3>Research &amp; Innovation</h3>
<ul>
  <li>110+ patents filed/granted</li>
  <li>700+ research papers in indexed journals</li>
  <li>Active incubation centre for entrepreneurship and startup ideas</li>
</ul>
<h3>Contact</h3>
<p>Phone: 020-27600050 | Email: pccoeadmin@gmail.com<br>Sector 26, Pradhikaran, Nigdi, Pune 411044</p>$body$,
  'general',
  ARRAY[1,2,3,4],
  ARRAY['all'],
  true,
  'published',
  now(),
  now()
),

-- ── 2. Academic Programs ─────────────────────────────────────────────────────
(
  'a1000000-0000-0000-0000-000000000002',
  'Academic Programs at PCCOE',
  'Full list of B.Tech, M.Tech, MCA, B.Voc and Ph.D. programs with multidisciplinary minors, honors options, full-semester internship and MOOCs credit recognition.',
  $body$<h2>Academic Programs at PCCOE</h2>
<p>PCCOE operates as an <strong>autonomous institute</strong> under SPPU, offering 24 programs across undergraduate, postgraduate and doctoral levels.</p>
<h3>Undergraduate — B.Tech Programs</h3>
<ul>
  <li>Computer Engineering</li>
  <li>Computer Engineering (Regional Language medium)</li>
  <li>Computer Science &amp; Engineering (AI &amp; ML)</li>
  <li>Information Technology</li>
  <li>Electronics &amp; Telecommunication Engineering (E&amp;TC)</li>
  <li>Mechanical Engineering</li>
  <li>Civil Engineering</li>
</ul>
<h3>Postgraduate — M.Tech Programs</h3>
<ul>
  <li>M.Tech Computer Engineering</li>
  <li>M.Tech E&amp;TC — VLSI Engineering</li>
  <li>M.Tech Mechanical — Design Engineering</li>
  <li>M.Tech Mechanical — Computational Mechanics</li>
  <li>M.Tech AI &amp; Data Science</li>
  <li>M.Tech Civil — Construction &amp; Management</li>
</ul>
<h3>Other Programs</h3>
<ul>
  <li><strong>MCA</strong> — Master of Computer Applications</li>
  <li><strong>Ph.D.</strong> — Computer, E&amp;TC, Mechanical, Civil Engineering</li>
  <li><strong>B.Voc</strong> — Bachelor of Vocation (6 programs)</li>
  <li><strong>B.Tech for Working Professionals</strong></li>
</ul>
<h3>Academic Features</h3>
<ul>
  <li>Choice Based Credit System (CBCS) with continuous internal evaluation</li>
  <li><strong>Multidisciplinary Minors</strong> (14 credits) — pursue interests outside your branch</li>
  <li><strong>Minor and Honor Degree</strong> certifications for specialization</li>
  <li><strong>Full Semester Internship</strong> option in industry or abroad</li>
  <li>MOOCs credit recognition and self-paced learning</li>
  <li>Outcome-Based Education (OBE) framework</li>
</ul>
<h3>Department Heads (HODs)</h3>
<ul>
  <li>Civil Engineering — Dr. A. K. Gaikwad</li>
  <li>Computer Engineering — Dr. Sonali D. Patil</li>
  <li>CSE (AI &amp; ML) — Dr. Anuradha Thakare</li>
  <li>Information Technology — Dr. Jayashree V. Katti</li>
  <li>E&amp;TC Engineering — Dr. Kishor S. Kinage</li>
  <li>Applied Sciences &amp; Humanities — Dr. Leena Sharma</li>
  <li>MCA — Dr. Ashvini C. Ladekar</li>
</ul>$body$,
  'general',
  ARRAY[1,2,3,4],
  ARRAY['all'],
  false,
  'published',
  now(),
  now()
),

-- ── 3. Admissions & Fee Structure ───────────────────────────────────────────
(
  'a1000000-0000-0000-0000-000000000003',
  'Admissions & Fee Structure',
  'DTE Code 6175. CAP-based admissions for B.Tech. Fee: Open ₹1,77,746 | OBC/EWS ₹1,01,224 | SC/ST ₹1,746. Hostel capacity: 300 boys, 150 girls (first year).',
  $body$<h2>Admissions at PCCOE</h2>
<p>PCCOE (DTE Code: <strong>6175</strong>) uses the <strong>Centralized Admission Process (CAP)</strong> administered by the Directorate of Technical Education (DTE), Maharashtra for B.Tech first-year admissions.</p>
<h3>Admission Process — B.Tech</h3>
<ul>
  <li>Complete seat acceptance via CET login (Freeze or Betterment option)</li>
  <li>Fill the ERP Admission Form via the PCCOE pre-admission portal</li>
  <li>Bring original documents for verification on the allotted date</li>
  <li>Complete fee payment</li>
  <li>Confirm seat on the CET Portal</li>
</ul>
<h3>Fee Structure (2025–26)</h3>
<ul>
  <li><strong>Open Category (Maharashtra)</strong>: ₹1,77,746 per year</li>
  <li><strong>OBC / EWS / EBC / SEBC</strong>: ₹1,01,224 per year</li>
  <li><strong>SC / ST</strong>: ₹1,746 per year</li>
  <li>Additional eligibility fees apply for non-Maharashtra / NRI students</li>
</ul>
<h3>Seats Available (B.Tech)</h3>
<ul>
  <li>Computer Engineering — 240 seats</li>
  <li>Information Technology — 120 seats</li>
  <li>E&amp;TC Engineering — 120 seats</li>
  <li>Mechanical Engineering — 120 seats</li>
  <li>Civil Engineering — 60 seats</li>
  <li>CSE (AI &amp; ML) — 60 seats</li>
</ul>
<h3>Hostel (First Year Capacity)</h3>
<ul>
  <li>Boys Hostel: <strong>300 seats</strong></li>
  <li>Girls Hostel: <strong>150 seats</strong></li>
</ul>
<h3>Scholarships</h3>
<p>Multiple government scholarships are available for eligible students — see the Scholarships article for the full list.</p>
<h3>Contact</h3>
<p>Phone: +91-8087174347 | Email: pccoeadmin@gmail.com</p>$body$,
  'general',
  ARRAY[1],
  ARRAY['all'],
  false,
  'published',
  now(),
  now()
),

-- ── 4. Campus Facilities ─────────────────────────────────────────────────────
(
  'a1000000-0000-0000-0000-000000000004',
  'Campus Facilities',
  'Smart classrooms, 9728-title library with 43,105 volumes, IEEE e-journals, project labs, gym, canteen, solar panels, bank ATM and more on the 13-acre Nigdi campus.',
  $body$<h2>Campus Facilities</h2>
<h3>Classrooms &amp; Infrastructure</h3>
<p>The 13-acre campus has multiple buildings with <strong>smart classrooms</strong> equipped with digital boards and projectors. Wi-Fi connectivity is available campus-wide.</p>
<h3>Library</h3>
<ul>
  <li><strong>9,728 titles</strong> and <strong>43,105 volumes</strong></li>
  <li>148 national print journals</li>
  <li>IEEE and Elsevier Science Direct e-journal subscriptions</li>
  <li>~39,000 e-books and 130 NPTEL courses (4,600+ videos)</li>
  <li>Reading hall with seating for <strong>200 students</strong></li>
  <li>Open 8 AM – midnight daily, including weekends and holidays</li>
</ul>
<h3>Laboratories</h3>
<p>Departmental labs for all disciplines — programming, electronics, VLSI, mechanical design, CAD/CAM, civil and more. Includes a <strong>state-of-the-art MCQ lab</strong> in association with Bakers Gauges, project labs and a fabrication lab.</p>
<h3>Cafeteria &amp; Student Zones</h3>
<ul>
  <li>Spacious, hygienic canteen serving affordable daily meals</li>
  <li>Common lounges and outdoor areas for relaxation between classes</li>
  <li>Stationary shop and photocopy shop on campus</li>
  <li>Indian Overseas Bank ATM on campus</li>
</ul>
<h3>Health, Safety &amp; Support</h3>
<ul>
  <li>On-campus medical facility for basic healthcare and first aid</li>
  <li>CCTV surveillance and security personnel across campus</li>
</ul>
<h3>Event Spaces</h3>
<ul>
  <li><strong>Auditorium</strong> — large venue for seminars, workshops and cultural events</li>
  <li>Seminar halls and multi-purpose rooms for departmental sessions</li>
</ul>
<h3>Green Campus</h3>
<p>Solar panels installed for hostel power, landscaped green spaces maintained throughout campus.</p>
<h3>Transportation</h3>
<p>College bus facility for students commuting from Pune and Pimpri-Chinchwad areas. Campus is also walkable from <strong>Akurdi Railway Station</strong>.</p>$body$,
  'facilities',
  ARRAY[1,2,3,4],
  ARRAY['all'],
  false,
  'published',
  now(),
  now()
),

-- ── 5. Library ───────────────────────────────────────────────────────────────
(
  'a1000000-0000-0000-0000-000000000005',
  'Central Library',
  '9,728 titles, 43,105 volumes, IEEE + Elsevier subscriptions, 39,000 e-books, NPTEL videos, KOHA + RFID system. Open 8 AM to midnight every day.',
  $body$<h2>Central Library</h2>
<p>Established in 1999, the Central Library supports academic and research needs with both physical and digital resources managed via the <strong>KOHA Library Management Software</strong> with an RFID system.</p>
<h3>Collection at a Glance</h3>
<ul>
  <li><strong>9,728 titles</strong> across engineering and allied subjects</li>
  <li><strong>43,105 volumes</strong> of textbooks and reference books</li>
  <li><strong>148 national print journals</strong> and periodicals</li>
  <li><strong>IEEE</strong> and <strong>Elsevier Science Direct</strong> digital journal subscriptions</li>
  <li>~<strong>39,000 e-books</strong></li>
  <li><strong>130 NPTEL courses</strong> with 4,604 video lectures</li>
  <li>Access to <strong>Rashtriya e-Pustakalaya</strong> (National Digital Library of India)</li>
</ul>
<h3>Facilities</h3>
<ul>
  <li><strong>Reading hall</strong> — seating for 200 students</li>
  <li><strong>Digital library</strong> section with internet connectivity</li>
  <li>Engineering reference section and multimedia access</li>
  <li>E-Library portal via <strong>Knimbus</strong> platform (access from anywhere)</li>
</ul>
<h3>Timings</h3>
<p>The reading hall is open <strong>8:00 AM to midnight</strong>, seven days a week including weekends and public holidays.</p>
<h3>Book Bank</h3>
<p>A Book Bank scheme is available for high-achieving and economically disadvantaged students across all academic years. Apply at the library counter at the start of each semester.</p>
<h3>Also Available</h3>
<ul>
  <li>Competitive exam preparation books (GATE, GRE, TOEFL)</li>
  <li>Literary works — novels, biographies, fiction</li>
  <li>Indian Standards Codes and handbooks</li>
</ul>$body$,
  'facilities',
  ARRAY[1,2,3,4],
  ARRAY['all'],
  false,
  'published',
  now(),
  now()
),

-- ── 6. Hostel Life ───────────────────────────────────────────────────────────
(
  'a1000000-0000-0000-0000-000000000006',
  'Hostel Life at PCCOE',
  'Boys hostel: 170 double + 99 triple rooms. Girls hostel: 10 double + 240 triple rooms. Wi-Fi, mess, gym, solar power, 24x7 security.',
  $body$<h2>Hostel Life at PCCOE</h2>
<p>PCCOE provides separate on-campus hostels for boys and girls with modern amenities and 24x7 security.</p>
<h3>Room Capacity</h3>
<ul>
  <li><strong>Boys Hostel</strong>: 170 double-seated rooms + 99 triple-seated rooms (across old and new buildings)</li>
  <li><strong>Girls Hostel</strong>: 10 double-seated rooms + 240 triple-seated rooms</li>
  <li>First-year capacity: 300 (boys), 150 (girls)</li>
</ul>
<h3>Amenities</h3>
<ul>
  <li>Wi-Fi connectivity in hostel premises</li>
  <li>Mess facility with daily meals</li>
  <li>Common rooms and recreational spaces</li>
  <li>Dedicated study areas</li>
  <li>Gymnasium with equipment</li>
  <li>Solar panels for power — uninterrupted electricity</li>
</ul>
<h3>Safety &amp; Security</h3>
<ul>
  <li>24x7 security personnel and CCTV coverage</li>
  <li>Warden supervision in both hostels</li>
  <li>Visitor entry-exit logs maintained</li>
</ul>
<h3>Things to Know</h3>
<ul>
  <li>Apply for hostel early — seats fill up quickly, especially for first years</li>
  <li>Mess food quality varies; the campus canteen is a popular alternative</li>
  <li>Ragging is strictly prohibited — report any issues to the Anti-Ragging Committee</li>
  <li>Hostel rules (curfew, guest policy) are communicated at the start of each year</li>
</ul>$body$,
  'hostel',
  ARRAY[1,2,3,4],
  ARRAY['all'],
  false,
  'published',
  now(),
  now()
),

-- ── 7. Sports & Recreation ───────────────────────────────────────────────────
(
  'a1000000-0000-0000-0000-000000000007',
  'Sports & Recreation at PCCOE',
  'Cricket, football, basketball, volleyball, badminton, table tennis, chess. 4 students selected for SPPU inter-university teams in 2025–26. Director of Sports: Mr. Santosh Pacharane.',
  $body$<h2>Sports &amp; Recreation at PCCOE</h2>
<p>The Sports Department, led by <strong>Mr. Santosh Pacharane</strong> (Director of Physical Education &amp; Sports), coordinates all athletic activities, university-level participation and on-campus competitions.</p>
<h3>Outdoor Sports</h3>
<ul>
  <li>Cricket</li>
  <li>Football</li>
  <li>Basketball</li>
  <li>Volleyball</li>
</ul>
<h3>Indoor Sports</h3>
<ul>
  <li>Badminton</li>
  <li>Table Tennis</li>
  <li>Chess</li>
  <li>Carrom</li>
</ul>
<h3>Achievements (2025–26)</h3>
<ul>
  <li><strong>4 students</strong> selected for SPPU teams — competing in West Zone and All India Inter-University competitions in volleyball, basketball and football</li>
  <li><strong>19 students</strong> selected for Pune District Team in inter-zonal competitions</li>
  <li>Girls Table Tennis team: <strong>Winners</strong></li>
  <li>Boys Table Tennis, Girls Volleyball, Boys Cricket, Boys Football: <strong>Runners-Up</strong> (Pune District Zonal Sports Committee)</li>
</ul>
<h3>Facilities</h3>
<ul>
  <li>Sports grounds and courts on campus</li>
  <li>Gymnasium with equipment (also available for hostel students)</li>
  <li>Inter-collegiate and inter-zonal tournaments organized on campus</li>
</ul>
<h3>Note</h3>
<p>Sports facility access may be restricted during academic hours. Contact the Sports Department for practice schedules: santosh.pacharane@pccoepune.org | 9890577774</p>$body$,
  'facilities',
  ARRAY[1,2,3,4],
  ARRAY['all'],
  false,
  'published',
  now(),
  now()
),

-- ── 8. Placements & Career ───────────────────────────────────────────────────
(
  'a1000000-0000-0000-0000-000000000008',
  'Placements & Career at PCCOE',
  '~85% placement rate. TCS: 640 offers, Cognizant: 392, Accenture: 219. Year-wise training from communication skills (SE) to mock interviews (BE). Dean: Dr. Shitalkumar Rawandale.',
  $body$<h2>Placements &amp; Career at PCCOE</h2>
<p>PCCOE''s <strong>Training and Placement Cell</strong> reports approximately <strong>85% of eligible students placed</strong> every year in reputed companies. Dean: <strong>Dr. Shitalkumar Rawandale</strong> (s.rawandale@gmail.com | +91 99754 90622).</p>
<h3>Major Recruiters &amp; Offer Stats</h3>
<ul>
  <li><strong>TCS</strong> — 4,500 applicants, 640 offers</li>
  <li><strong>Cognizant</strong> — 2,000 applicants, 392 offers</li>
  <li><strong>L&amp;T Infotech</strong> — 2,500 applicants, 220 offers</li>
  <li><strong>Accenture</strong> — 2,200 applicants, 219 offers</li>
  <li>IBM, Infosys, Wipro, Oracle, HP, KPIT, TechMahindra and more</li>
</ul>
<h3>Year-Wise Training Program</h3>
<ul>
  <li><strong>SE (2nd Year)</strong>: Communication skills training</li>
  <li><strong>TE (3rd Year)</strong>: Soft skills development + aptitude preparation</li>
  <li><strong>BE (4th Year)</strong>: Mock interviews, group discussion practice, interview coaching</li>
</ul>
<h3>Resources Available</h3>
<ul>
  <li>Language and aptitude laboratories</li>
  <li>Resume-building and personality development workshops</li>
  <li>Industry interaction events and alumni mentoring</li>
  <li>Internship facilitation (TE year recommended)</li>
</ul>
<h3>Tips for Students</h3>
<ul>
  <li>Maintain CGPA above 6.0 — many companies have this as a cutoff</li>
  <li>Start competitive programming (LeetCode, HackerRank) from SE year</li>
  <li>Internship in TE can lead to Pre-Placement Offers (PPOs)</li>
  <li>Attend placement cell sessions regularly — volunteers develop faster career growth</li>
</ul>$body$,
  'placements',
  ARRAY[2,3,4],
  ARRAY['all'],
  false,
  'published',
  now(),
  now()
),

-- ── 9. Scholarships ──────────────────────────────────────────────────────────
(
  'a1000000-0000-0000-0000-000000000009',
  'Scholarships at PCCOE',
  'Government scholarships for SC/ST, OBC, EBC, EWS, disabled students — post-matric, freeship, Shahu Maharaj merit scholarship, Panjabrao Deshmukh living allowance and AICTE schemes.',
  $body$<h2>Scholarships at PCCOE</h2>
<p>Multiple government scholarships are available to eligible students. Applications are processed via the <strong>Maharashtra government''s mahait portal</strong>.</p>
<h3>Social Justice &amp; Special Assistance Department</h3>
<ul>
  <li><strong>Government of India Post-Matric Scholarship</strong> — for SC/ST students</li>
  <li><strong>Tuition Fee and Examination Fee Waiver (Freeship)</strong> — for eligible backward class students</li>
  <li><strong>Rajarshri Chhatrapati Shahu Maharaj Merit Scholarship</strong></li>
  <li><strong>Post-Matric Aid for Persons with Disabilities</strong></li>
</ul>
<h3>Directorate of Technical Education (DTE)</h3>
<ul>
  <li><strong>Rajarshi Chhatrapati Shahu Maharaj Tuition Assistance</strong> — EBC (Economically Backward Class) category</li>
  <li><strong>Dr. Panjabrao Deshmukh Living Allowance Scheme</strong> — monthly stipend for eligible students</li>
</ul>
<h3>AICTE Scholarships</h3>
<ul>
  <li>AICTE Pragati Scholarship (for girls)</li>
  <li>AICTE Saksham Scholarship (for differently-abled students)</li>
  <li>Various AICTE fellowship schemes for PG and doctoral students</li>
</ul>
<h3>How to Apply</h3>
<ul>
  <li>Visit the Maharashtra scholarship portal: <strong>mahadbt.maharashtra.gov.in</strong></li>
  <li>Collect required documents: caste certificate, income certificate, previous marksheets, Aadhaar, bank passbook</li>
  <li>Apply at the start of each academic year — deadlines are strict</li>
  <li>Visit the college scholarship cell for guidance: Student Development and Welfare (SDW) office</li>
</ul>$body$,
  'general',
  ARRAY[1,2,3,4],
  ARRAY['all'],
  false,
  'published',
  now(),
  now()
),

-- ── 10. Exams Cell & Assessment ──────────────────────────────────────────────
(
  'a1000000-0000-0000-0000-000000000010',
  'Exam Cell & Assessment System',
  'Autonomous exam system with internal + external assessment. Controller: Dr. Sunil Tade. Grievance redressal, transcript requests, grade cards and percentage certificates.',
  $body$<h2>Exam Cell &amp; Assessment System</h2>
<p>As an autonomous institute, PCCOE runs its own examination system — administered by the <strong>Examinations Cell</strong> — separate from SPPU''s direct control.</p>
<h3>Assessment Structure</h3>
<ul>
  <li><strong>Internal Assessment (IA)</strong>: Formative assessments, unit tests and assignments conducted by faculty throughout the semester</li>
  <li><strong>External Assessment (EA)</strong>: End-of-semester exams coordinated with external examiners</li>
  <li>Continuous internal evaluation contributes to the final grade</li>
</ul>
<h3>Exam Cell Leadership</h3>
<ul>
  <li><strong>Controller of Examinations</strong>: Dr. Sunil L. Tade (25+ years experience)</li>
  <li><strong>Deputy Controller</strong>: Dr. Arif Bagwan</li>
  <li><strong>Associate Dean, Examinations</strong>: Dr. Pravin Game</li>
  <li>Contact: coe@pccoepune.org | 020-27600145</li>
</ul>
<h3>Services Available</h3>
<ul>
  <li>Grade cards and marksheets</li>
  <li>Official transcripts (for higher education applications)</li>
  <li>Percentage conversion certificates</li>
  <li>Medium of instruction certificate</li>
  <li>Degree certificates post-result declaration</li>
</ul>
<h3>Grievance Redressal</h3>
<p>A defined grievance framework is in place for students who wish to challenge results or raise exam-related concerns. Approach the Exam Cell office within the stipulated time after result declaration.</p>
<h3>Key Tips</h3>
<ul>
  <li>Check the <strong>Academic Calendar</strong> published at the start of each semester for internal exam dates</li>
  <li>Internal exam dates are fixed — missing them significantly impacts your grade</li>
  <li>Apply for transcripts well in advance if applying for higher education abroad (processing takes time)</li>
</ul>$body$,
  'exams',
  ARRAY[1,2,3,4],
  ARRAY['all'],
  false,
  'published',
  now(),
  now()
),

-- ── 11. Rankings & Awards ────────────────────────────────────────────────────
(
  'a1000000-0000-0000-0000-000000000011',
  'Rankings & Achievements',
  'NAAC A Grade (3.20), NBA accredited, 110+ patents, India Today 58th, Outlook 37th. Team Kratos national champions, Team Maverick world rank 6.',
  $body$<h2>Rankings &amp; Achievements</h2>
<h3>Institutional Rankings (2024–25)</h3>
<ul>
  <li><strong>India Today</strong>: 58th — Top Private Engineering Colleges, India</li>
  <li><strong>Outlook iCARE</strong>: 37th — Top 200 Private Engineering Institutes, India</li>
  <li><strong>DataQuest T-School</strong>: 6th in West Zone, 29th nationally (private)</li>
  <li><strong>The Week–Hansa Research</strong>: 11th in West Zone, 68th nationally</li>
  <li><strong>Times All India Engineering Survey</strong>: 14th — Top 175 Engineering Institutes</li>
  <li><strong>Silicon India</strong>: 22nd nationally, 5th in West India</li>
</ul>
<h3>Accreditations</h3>
<ul>
  <li>NAAC ''A'' Grade — Score: <strong>3.20</strong></li>
  <li>NBA Accredited (all 4 PG programs: 3-year accreditation through 2028)</li>
  <li>ISO 21001:2018 and ISO 9001:2015 Certified</li>
  <li>Autonomous Institute under SPPU</li>
</ul>
<h3>Student Team Achievements (2024–25)</h3>
<ul>
  <li><strong>Team Kratos Racing</strong> (Formula Bharat): <strong>Overall Champions</strong> — Dynamics Winner + Efficiency Awards</li>
  <li><strong>Team Maverick India</strong> (UAV/Drones): <strong>World Rank 6</strong> — SAE Aero Design West 2025; All India Rank 2 — NIDAR 2026</li>
  <li><strong>Team Red Baron</strong> (E-BAJA SAE): <strong>Overall Runner-Up</strong>, AIR 3 — 2025–26</li>
  <li><strong>Team Solarium</strong> (Solar Vehicle): <strong>Overall Champions</strong> — ESVC 3000 2025 + multiple design &amp; innovation awards</li>
</ul>
<h3>Research Output</h3>
<ul>
  <li>110+ patents filed/granted</li>
  <li>700+ research papers in Scopus/indexed journals</li>
</ul>$body$,
  'general',
  ARRAY[1,2,3,4],
  ARRAY['all'],
  false,
  'published',
  now(),
  now()
),

-- ── 12. Alumni Association ───────────────────────────────────────────────────
(
  'a1000000-0000-0000-0000-000000000012',
  'Alumni Association — Kalpataru',
  'Registered in 2005 (Reg. No. Maharashtra/150/2005/Pune). Online portal at pccoepune.almaconnect.com connects 25+ years of PCCOE alumni for mentorship and placements.',
  $body$<h2>Alumni Association — Kalpataru (कल्पतरू)</h2>
<p>The PCCOE Alumni Association, named <strong>Kalpataru</strong>, was established in <strong>2005</strong> and officially registered under the Societies Registration Act, 1860 (Registration No: <strong>Maharashtra/150/2005/Pune</strong>).</p>
<h3>What Kalpataru Offers</h3>
<ul>
  <li>Online alumni portal with social-media-style interaction and profile management</li>
  <li>Direct bulk communication between alumni and the institution</li>
  <li>Updates on career progressions and achievements of fellow alumni</li>
  <li>Platform for alumni willing to mentor current students or support the institution</li>
</ul>
<h3>How It Helps Students</h3>
<ul>
  <li>Connect with PCCOE graduates working across India and abroad for career guidance</li>
  <li>Referrals and networking for internships and job opportunities</li>
  <li>Industry insights from alumni who are working professionals and entrepreneurs</li>
  <li>Annual Alumni Meet — networking with deans, HODs and industry leaders</li>
</ul>
<h3>Recent Activity</h3>
<p>The 2026 Alumni Meet (March 21, 2026) brought together approximately <strong>110 alumni</strong> and <strong>90 institutional leaders</strong> including academic deans and department heads, focused on strengthening industry-academia collaboration.</p>
<h3>Join the Network</h3>
<p>Alumni and students can connect via the official portal: <strong>pccoepune.almaconnect.com</strong></p>$body$,
  'general',
  ARRAY[3,4],
  ARRAY['all'],
  false,
  'published',
  now(),
  now()
),

-- ── 13. Swartarang ───────────────────────────────────────────────────────────
(
  'a1000000-0000-0000-0000-000000000013',
  'Swartarang — Annual Cultural Festival',
  'PCCOE''s flagship annual cultural fest featuring dance, music, fashion shows, rangoli, hobby exhibitions and celebrity guest interactions. Swartarang 2026 already announced.',
  $body$<h2>Swartarang — Annual Cultural Festival</h2>
<p>Swartarang is PCCOE''s flagship annual cultural and social gathering, celebrated with enthusiasm by students and faculty. It creates a stage for creativity, performance and collaboration across all disciplines. <strong>Swartarang 2026</strong> has been announced for this academic year.</p>
<h3>Key Highlights</h3>
<ul>
  <li><strong>Rangoli Competitions</strong> — Art and creativity with themed social messages</li>
  <li><strong>Hobby Exhibitions</strong> — Students display personal talents: sketching, poetry, crafts, collections and more</li>
  <li><strong>Dance &amp; Music Performances</strong> — Solo and group performances reflecting cultural diversity</li>
  <li><strong>Ramp Walk &amp; Fashion Show</strong> — Theme-based fashion show empowering self-expression</li>
  <li><strong>Guest Interactions</strong> — Celebrated personalities invited to interact and inspire students</li>
</ul>
<h3>Student Engagement</h3>
<p>Swartarang brings together performers, event volunteers, judges and faculty coordinators — fostering leadership, teamwork and cultural pride. It is one of the most anticipated events of the academic year.</p>
<h3>How to Participate</h3>
<p>Watch for announcements from the Student Council (Cultural Secretary: Janhavi Chati, 7709575064) and your department association. Registrations open a few weeks before the festival.</p>$body$,
  'events',
  ARRAY[1,2,3,4],
  ARRAY['all'],
  false,
  'published',
  now(),
  now()
),

-- ── 14. KSHITIJ ──────────────────────────────────────────────────────────────
(
  'a1000000-0000-0000-0000-000000000014',
  'KSHITIJ — Annual Technical Festival',
  'PCCOE''s annual college-wide technical fest. KSHITIJ 2026 already announced. Features coding contests, project exhibitions, technical paper presentations, workshops and industry talks.',
  $body$<h2>KSHITIJ — Annual Technical Festival</h2>
<p>KSHITIJ is PCCOE''s annual college-wide technical festival bringing together students from all departments for competitions, exhibitions and industry interactions. <strong>KSHITIJ 2026</strong> has been announced for this academic year.</p>
<h3>Typical Events</h3>
<ul>
  <li><strong>Coding Competitions</strong> — Individual and team-based programming contests</li>
  <li><strong>Project Exhibitions</strong> — Students showcase semester and research projects to industry judges</li>
  <li><strong>Technical Paper Presentations</strong> — Research and innovation presented in a conference format</li>
  <li><strong>Hackathons</strong> — Overnight or day-long problem-solving sprints</li>
  <li><strong>Workshops</strong> — Hands-on sessions by industry professionals and alumni</li>
  <li><strong>Guest Lectures</strong> — Industry experts and entrepreneurs as keynote speakers</li>
</ul>
<h3>Why Participate</h3>
<ul>
  <li>Build your technical portfolio with real competition experience</li>
  <li>Network with industry professionals and potential recruiters</li>
  <li>Prizes, certificates and recognition across categories</li>
  <li>Volunteering provides event management and leadership experience</li>
</ul>
<h3>How to Get Involved</h3>
<p>Watch for announcements on the college notice board, department association pages and the PCCOE website. Registration typically opens 3–4 weeks before the event.</p>$body$,
  'events',
  ARRAY[1,2,3,4],
  ARRAY['all'],
  false,
  'published',
  now(),
  now()
),

-- ── 15. INSPERIA ─────────────────────────────────────────────────────────────
(
  'a1000000-0000-0000-0000-000000000015',
  'INSPERIA — MCA Technical & Innovation Festival',
  'Annual tech fest by the MCA department: Future Forge, Tech Tank (Shark Tank style), Human Ludo and Roadies-style challenges. Open to all departments.',
  $body$<h2>INSPERIA — Technical &amp; Innovation Festival</h2>
<p>Organized by the <strong>MCA (Master of Computer Applications)</strong> department, INSPERIA blends technology, innovation and fun competitions to push students beyond the classroom.</p>
<h3>Featured Events</h3>
<ul>
  <li><strong>Future Forge</strong> — Present solutions to real-world problems with innovation at the core</li>
  <li><strong>Tech Tank</strong> — Pitch entrepreneurship and tech ideas to industry professionals (Shark Tank style)</li>
  <li><strong>Roadies-style Team Challenge</strong> — Physical and logical tasks promoting teamwork and endurance</li>
  <li><strong>Human Ludo</strong> — Life-sized strategic team game blending fun with planning skills</li>
</ul>
<h3>Why Participate</h3>
<ul>
  <li>Exposure to industry perspectives through professional judges and speakers</li>
  <li>Opportunity to pitch real ideas and receive feedback</li>
  <li>Build collaboration and problem-solving skills outside regular coursework</li>
</ul>
<h3>Who Can Join</h3>
<p>INSPERIA is open to students from <strong>all departments</strong>, not just MCA. Watch for announcements from the MCA department and the Collegiate Clubs board for registration details.</p>$body$,
  'events',
  ARRAY[1,2,3,4],
  ARRAY['all'],
  false,
  'published',
  now(),
  now()
),

-- ── 16. SPECTRUM ─────────────────────────────────────────────────────────────
(
  'a1000000-0000-0000-0000-000000000016',
  'SPECTRUM — First Year Technical Symposium',
  'AS&H Department''s symposium for SE students: Brain Dasher, Tech Treasure Hunt, Electrica, E-Paradox and War of Words. First-year students run the entire event.',
  $body$<h2>SPECTRUM — First Year Technical Symposium</h2>
<p>Organized by the <strong>Applied Sciences &amp; Humanities (AS&amp;H) Department</strong>, SPECTRUM is a technical symposium targeted at second-year (SE) students to explore innovation early in their engineering journey.</p>
<h3>Events at SPECTRUM</h3>
<ul>
  <li><strong>Brain Dasher &amp; High-Ping</strong> — Competitive challenges promoting logic and speed</li>
  <li><strong>Tech Treasure Hunt</strong> — Gamified team-based problem solving</li>
  <li><strong>Chem Prastuti / Electrica</strong> — Subject-oriented science and engineering contests</li>
  <li><strong>E-Paradox</strong> — Creative engineering puzzles</li>
  <li><strong>War of Words</strong> — Debate-style event for communication and argumentation</li>
</ul>
<h3>Student Leadership</h3>
<p>A defining feature of SPECTRUM: <strong>SE student volunteers manage all planning, logistics and execution</strong> — building leadership and coordination skills from the very start of their engineering journey.</p>
<h3>Why Attend</h3>
<p>One of the best ways for SE students to make friends across branches, discover interests beyond academics and start building a college portfolio early.</p>$body$,
  'events',
  ARRAY[1,2],
  ARRAY['all'],
  false,
  'published',
  now(),
  now()
),

-- ── 17. Department Events ────────────────────────────────────────────────────
(
  'a1000000-0000-0000-0000-000000000017',
  'Department-Level Events & Hackathons',
  'Hackathons, project exhibitions, MUN, Engineers Day, farewell functions and more — organized by CESA, MESA, ETeSA, CiESA and ITSA throughout the year.',
  $body$<h2>Department-Level Events &amp; Hackathons</h2>
<p>Beyond college-wide festivals, each department runs its own calendar of technical and social events throughout the year.</p>
<h3>Civil Engineering — CiESA Events</h3>
<ul>
  <li><strong>Model United Nations (MUN)</strong> — Debate and diplomatic reasoning</li>
  <li><strong>Build Next / Sthapatya</strong> — Civil engineering problem-solving challenges</li>
  <li><strong>Water Day / Awareness Programs</strong> — Environmental engagement</li>
  <li>Teacher''s Day Celebrations, Induction Ceremonies, Farewell Functions</li>
</ul>
<h3>IT, CS &amp; E&amp;TC Departments</h3>
<ul>
  <li><strong>Hackathons</strong> — AI/ML, embedded systems and web dev themes; open to cross-department teams</li>
  <li><strong>Project Exhibitions &amp; PBL Showcases</strong> — Present projects to faculty and industry guests</li>
  <li><strong>Engineers Day</strong> — Themed contests and quizzes celebrating engineering</li>
  <li><strong>Coding Competitions</strong> — Intra and inter-college competitive programming</li>
</ul>
<h3>Benefits of Participating</h3>
<ul>
  <li>Real problem-solving experience and skill building</li>
  <li>Leadership experience for student organizers</li>
  <li>Inter-department collaboration and networking</li>
  <li>Industry exposure through expert judges and speakers</li>
</ul>$body$,
  'events',
  ARRAY[1,2,3,4],
  ARRAY['all'],
  false,
  'published',
  now(),
  now()
),

-- ── 18. Student Associations ─────────────────────────────────────────────────
(
  'a1000000-0000-0000-0000-000000000018',
  'Student Department Associations',
  'CESA, MESA, ETeSA, CiESA, ITSA — department-level student bodies organizing technical events, workshops and social activities. Join at the start-of-year induction.',
  $body$<h2>Student Department Associations</h2>
<p>Each department has an official student association that organizes technical events, workshops and social activities.</p>
<h3>Associations at a Glance</h3>
<ul>
  <li><strong>CESA</strong> — Computer Engineering Students Association<br>Coordinator: Mr. Rahul Pitale</li>
  <li><strong>MESA</strong> — Mechanical Engineering Students Association<br>Coordinator: Mrs. V. Y. Gaikhe</li>
  <li><strong>ETeSA</strong> — E&amp;TC Students Association<br>Coordinator: Mrs. A. S. Shinde | President: Maitreyee Bhoite (TE E&amp;TC)</li>
  <li><strong>CiESA</strong> — Civil Engineering Students Association<br>Coordinator: Dr. Suresh Nama</li>
  <li><strong>ITSA</strong> — Information Technology Students Association<br>Coordinator: Mrs. Shraddha Tawade</li>
</ul>
<h3>MESA Leadership (2025–26)</h3>
<ul>
  <li>President: Ashay Jambhorkar | Vice President: Aditya Patil</li>
  <li>Treasurer: Abhishek Wanare | Social Media: Dashmeet Singh Suri</li>
  <li>Event Management: Rugved Chemate</li>
</ul>
<h3>How to Join</h3>
<p>Attend the induction event at the start of each academic year. Student positions are elected or selected — watch for announcements on department notice boards and association social media pages.</p>$body$,
  'clubs',
  ARRAY[1,2,3,4],
  ARRAY['all'],
  false,
  'published',
  now(),
  now()
),

-- ── 19. Technical Teams ──────────────────────────────────────────────────────
(
  'a1000000-0000-0000-0000-000000000019',
  'Technical Teams & Motor Sports Clubs',
  'Team Kratos (national champions), Team Maverick (world rank 6), Team Solarium (overall champions ESVC 2025), Team Red Baron (AIR 3 E-BAJA). Plus Coding Club, Team Ambush, Automatons.',
  $body$<h2>Technical Teams &amp; Motor Sports Clubs</h2>
<p>PCCOE''s competitive technical teams participate in national and international engineering competitions. Championship results in 2024–25 put PCCOE among the top performing institutes in India.</p>
<h3>Teams &amp; Recent Achievements</h3>
<ul>
  <li><strong>Team Kratos Racing Electric</strong> (Formula Student): <strong>Overall National Champions</strong> — Formula Bharat 2024–25. Dynamics Winner + Efficiency Award. ~40 student members.</li>
  <li><strong>Team Maverick India</strong> (Fixed-Wing UAV / Drones): <strong>World Rank 6</strong> — SAE Aero Design West 2025. <strong>All India Rank 2</strong> — NIDAR 2026.</li>
  <li><strong>Team Solarium</strong> (Solar Vehicle): <strong>Overall Champions</strong> — ESVC 3000 2025. Multiple design and innovation category wins.</li>
  <li><strong>Team Red Baron</strong> (E-BAJA SAE / All-Terrain Vehicle): <strong>Overall Runner-Up</strong>, AIR 3 — 2025–26.</li>
  <li><strong>Team Automatons</strong> (Robotics): Participates in ABU ROBOCON and rover challenges.</li>
  <li><strong>Team Ambush</strong>: Develops automated multi-vegetable transplanters for agriculture.</li>
  <li><strong>Team Anantam</strong> (Rocketry &amp; Space): Model rocketry and CanSat development.</li>
  <li><strong>Coding Club</strong>: Competitive programming, cybersecurity, open-source. Participates in ICPC, GSoC, CTF and IEEE Xtreme.</li>
</ul>
<h3>How to Join</h3>
<p>Teams recruit at the start of each academic year via open trials or interviews. Follow team pages on Instagram and the college notice board. Skills in CAD, electronics, programming or fabrication are an advantage — but most teams train new recruits from scratch.</p>$body$,
  'clubs',
  ARRAY[1,2,3,4],
  ARRAY['all'],
  false,
  'published',
  now(),
  now()
),

-- ── 20. IEEE, IETE & Other Chapters ─────────────────────────────────────────
(
  'a1000000-0000-0000-0000-000000000020',
  'IEEE, IETE & Other Technical Chapters',
  'IEEE, IETE, ACM, ACM-W, GFG, NextGen Developers, Code Craft, Robohawk, PixelCraft, E-Cell — professional chapters with workshops, certifications and hackathon access.',
  $body$<h2>IEEE, IETE &amp; Other Technical Chapters</h2>
<p>PCCOE hosts multiple professional and open-source student chapters providing access to global networks, certifications, competitions and industry events.</p>
<h3>IEEE Student Branch</h3>
<ul>
  <li>Chairperson: Miss Lekha Kumbhar (TE E&amp;TC)</li>
  <li>Counselor: Mrs. Vijayalaxmi S. Kumbhar (Asst. Prof. E&amp;TC)</li>
  <li>Mentor: Dr. Santosh Randive (HOD E&amp;TC)</li>
</ul>
<p>IEEE membership: access to technical journals, global conferences, IEEE Xtreme competition and workshops.</p>
<h3>IETE Student Branch</h3>
<ul>
  <li>Counselor: Dr. Dipali Shende | Mentor: Dr. Santosh Randive (HOD E&amp;TC)</li>
</ul>
<h3>Other Active Clubs</h3>
<ul>
  <li><strong>ACM PCCOE</strong> — Association for Computing Machinery student chapter</li>
  <li><strong>ACM-W PCCOE</strong> — Women in Computing chapter</li>
  <li><strong>GFG Student Chapter</strong> — GeeksForGeeks chapter for DSA &amp; coding prep</li>
  <li><strong>NextGen Developers Club</strong> — Full-stack and app development</li>
  <li><strong>Code Craft</strong> — Competitive programming</li>
  <li><strong>Robohawk</strong> — Robotics and automation</li>
  <li><strong>PixelCraft Club</strong> — Design, UI/UX and digital arts</li>
  <li><strong>E-Cell</strong> — Entrepreneurship Cell for startup ideas</li>
  <li><strong>C-Cube</strong> — Project and innovation incubation</li>
</ul>
<h3>How to Join</h3>
<p>Open membership drives at the start of each semester. Annual fees are nominal (typically ₹200–500). Benefits include workshops, hackathon access, certifications and alumni networking.</p>$body$,
  'clubs',
  ARRAY[1,2,3,4],
  ARRAY['all'],
  false,
  'published',
  now(),
  now()
)

ON CONFLICT (id) DO NOTHING;
