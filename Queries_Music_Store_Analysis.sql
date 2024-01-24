/* Q1. Who is the senior most employee based on job title? */

 SELECT title, first_name, last_name
 FROM employee
 ORDER BY levels DESC
 LIMIT 1;

/* #Q2. Which countries have the most Invoices? */

 SELECT COUNT(*) as total_invoice, billing_country 
 FROM invoice
 GROUP BY billing_country
 ORDER BY total_invoice DESC;

/* #Q3. What are top 3 values of total invoice? */

 SELECT total  
 FROM invoice
 ORDER BY total DESC
 LIMIT 3;

/* Q4. Which city has the best customer? We would like to throw a promotional Music Festival in the city we made the most 
	 money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & 
	 sum of all invoice totals */

 SELECT SUM(total) as invoice_total, billing_city
 FROM Invoice
 GROUP BY billing_city
 ORDER BY invoice_total
 Limit 1;
 
 /* Q5. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write 
 		a query that returns the person who has spent the most money */
		
 SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) as total_spend 
 FROM customer as c
 JOIN invoice as i
 ON c.customer_id = i.customer_id
 GROUP BY c.customer_id
 ORDER BY total_spend DESC
 LIMIT 1;
 
/* Q6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list 
	   ordered alphabetically by email starting with A */
	
 SELECT DISTINCT c.email, c.first_name, c.last_name 
 FROM customer as c
 JOIN invoice as i ON c.customer_id = i.customer_id
 JOIN invoice_line as il ON i.invoice_id = il.invoice_id
 WHERE track_id IN (
 	SELECT t.track_id 
 	FROM track as t
 	JOIN genre as g
 	ON t.genre_id = g.genre_id
 	WHERE g.name = 'Rock'
 )
 ORDER BY c.email;
 
 /* Q7. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the 
 		Artist name and total track count of the top 10 rock bands */
 
 SELECT art.artist_id, art.name, COUNT(art.artist_id) as number_of_songs
 FROM track as t
 JOIN album as a ON a.album_id = t.album_id
 JOIN artist as art ON art.artist_id = a.artist_id
 JOIN genre as g ON g.genre_id = t.genre_id
 WHERE g.name LIKE 'Rock'
 GROUP BY art.artist_id
 ORDER BY number_of_songs DESC
 LIMIT 10;
 
 /* Q8. Return all the track names that have a song length longer than the average song length. Return the Name 
 		and Milliseconds for each track. Order by the song length with the longest songs listed first */

 SELECT name, milliseconds 
 FROM track
 WHERE milliseconds > (
 	SELECT AVG(milliseconds)
 	FROM track)
 ORDER BY milliseconds DESC;
 
 /* Q9. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name 
 		and total spent */
		
 WITH best_selling_artist AS (
 	SELECT artist.artist_id as artist_id, artist.name as artist_name, 
	 SUM(invoice_line.unit_price * invoice_line.quantity) as total_sales
 	FROM invoice_line 
 	JOIN track ON track.track_id = invoice_line.track_id
 	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
 )
 
 SELECT customer.customer_id, customer.first_name, customer.last_name, bsa.artist_name, 
  SUM(invoice_line.unit_price * invoice_line.quantity) as total_spent
 FROM invoice
 JOIN customer ON customer.customer_id = invoice.customer_id
 JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
 JOIN track ON track.track_id = invoice_line.track_id
 JOIN album ON album.album_id = track.album_id
 JOIN best_selling_artist as bsa ON bsa.artist_id = album.artist_id
 GROUP BY 1,2,3,4
 ORDER BY 5 DESC;
 
 /* Q10. We want to find out the most popular music Genre for each country. We determine the most popular genre 
 	as the genre with the highest amount of purchases. Write a query that returns each country along with the 
	top Genre. For countries where the maximum number of purchases is shared return all Genres */
	
 WITH popular_genre AS (
 	SELECT COUNT(invoice_line.quantity) AS purchase, customer.country, genre.name, genre.genre_id, 
	 ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) as RowNo
	FROM invoice_line
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	 ORDER BY 2 ASC, 1 DESC
 )
 SELECT * FROM popular_genre WHERE RowNo <=1;
 
 
 /* Q11. Write a query that determines the customer that has spent the most on music for each country. Write a query
 		 that returns the country along with the top customer and how much they spent. For countries where the top 
		 amount spent is shared, provide all customers who spent this amount */
		
 WITH Customer_with_country AS (
 	SELECT c.customer_id, c.first_name, c.last_name, i.billing_country, SUM(i.total) as total_spending,
	 ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(i.total) DESC) as RowNo
	FROM invoice as i
	JOIN customer as c 
	ON c.customer_id = i.customer_id
	GROUP BY 1,2,3,4
	 ORDER BY 4 ASC, 5 DESC
 )
 SELECT * FROM Customer_with_country WHERE RowNo <= 1;
		 