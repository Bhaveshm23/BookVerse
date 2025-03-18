// Base URL for the API (relative since it’s served by Spring Boot)
const API_URL = '/api/books';

// Fetch and display books on page load
document.addEventListener('DOMContentLoaded', () => {
    fetchBooks();
});

// Handle form submission
document.getElementById('bookForm').addEventListener('submit', (event) => {
    event.preventDefault();

    const book = {
        title: document.getElementById('title').value,
        author: document.getElementById('author').value,
        publishedDate: document.getElementById('date').value
    };

    addBook(book);
});

// Function to fetch books from the API
function fetchBooks() {
    fetch(API_URL)
        .then(response => response.json())
        .then(books => {
            const bookList = document.getElementById('bookList');
            bookList.innerHTML = ''; // Clear existing list
            books.forEach(book => {
                const li = document.createElement('li');
                li.textContent = `${book.title} by ${book.author}  published on: ${book.publishedDate})`;
                bookList.appendChild(li);
            });
        })
        .catch(error => console.error('Error fetching books:', error));
}

// Function to add a new book
function addBook(book) {
    fetch(API_URL, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(book)
    })
        .then(response => response.json())
        .then(() => {
            fetchBooks(); // Refresh the list
            document.getElementById('bookForm').reset(); // Clear the form
        })
        .catch(error => console.error('Error adding book:', error));
}