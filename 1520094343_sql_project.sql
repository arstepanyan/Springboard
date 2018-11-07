/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: ****
Password: ****

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
SELECT name
	FROM Facilities
  WHERE membercost <> 0

/* Q2: How many facilities do not charge a fee to members? */
SELECT count(*)
	FROM Facilities
  WHERE membercost = 0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid,
	   name,
	   membercost,
	   monthlymaintenance
	FROM Facilities
  WHERE membercost <> 0
    AND membercost < monthlymaintenance*0.2

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT *
	FROM Facilities
  WHERE facid IN (1, 5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT name,
	   monthlymaintenance,
	   (CASE WHEN monthlymaintenance <= 100 THEN 'cheap'
		     WHEN monthlymaintenance > 100 THEN 'expensive'
			 END) AS cheap_expensive
	FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT members.firstname,
	   members.surname
	FROM Members members
	JOIN ( 
          SELECT MAX(joindate) AS joindate
          	FROM Members
        ) sub
	ON members.joindate = sub.joindate

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT CONCAT(sub.fac_name, ', ', members.firstname, ' ', members.surname) AS court_member
	FROM Members members
	JOIN ( 
          SELECT DISTINCT
	   			 fac.name AS fac_name,
       			 book.memid
			FROM Facilities fac
			JOIN Bookings book
			  ON fac.facid = book.facid
		  WHERE fac.name LIKE '%tennis court%'
    	 ) sub
	  ON members.memid = sub.memid
  WHERE members.firstname NOT LIKE '%guest%'
  ORDER BY members.firstname


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT CONCAT(fac.name, ', ', mem.firstname) AS facility_member,
	   CASE WHEN mem.firstname LIKE '%guest%' THEN fac.guestcost * book.slots
	        WHEN mem.firstname NOT LIKE '%guest%' THEN fac.membercost * book.slots
	        END AS cost
	FROM Members mem
	JOIN Bookings book 
	  ON mem.memid = book.memid
	JOIN Facilities fac 
	  ON book.facid = fac.facid
   WHERE book.starttime LIKE '%2012-09-14%'
     AND (CASE WHEN mem.firstname LIKE '%guest%' THEN fac.guestcost * book.slots
	        WHEN mem.firstname NOT LIKE '%guest%' THEN fac.membercost * book.slots
	        END) > 30
   ORDER BY cost DESC 

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT CONCAT(sub.fac_name, ', ', mem.firstname) AS facility_member,
	   cost,
	   sub.starttime
	FROM Members mem
	JOIN (
           SELECT CASE WHEN book.memid = 0 THEN fac.guestcost * book.slots
                       WHEN book.memid <> 0 THEN fac.membercost * book.slots
        	            END AS cost,
                  fac.name as fac_name,
                  book.memid as memid,
                  book.starttime as starttime
        	FROM Bookings book
            JOIN Facilities fac
              ON book.facid = fac.facid
           WHERE book.starttime LIKE '%2012-09-14%'
    	 ) sub
      ON mem.memid = sub.memid
  WHERE cost > 30
  ORDER BY cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT sub.fac_name AS facility_name,
       SUM(sub.cost) AS total_revenue
	FROM Members mem
	JOIN (
           SELECT CASE WHEN book.memid = 0 THEN fac.guestcost * book.slots
                       WHEN book.memid <> 0 THEN fac.membercost * book.slots
        	            END AS cost,
                  fac.name as fac_name,
                  book.memid as memid
        	 FROM Bookings book
             JOIN Facilities fac
               ON book.facid = fac.facid
    	 ) sub
      ON mem.memid = sub.memid
   GROUP BY sub.fac_name
  HAVING total_revenue < 1000
   ORDER BY total_revenue