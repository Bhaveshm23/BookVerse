const API_URL = '/api/books';

// Fetch and display books on page load
document.addEventListener('DOMContentLoaded', () => {
    fetchBooks();
});

// Handle form submission
document.getElementById('bookForm').addEventListener('submit', async (event) => {
    event.preventDefault();

    const title = document.getElementById('title').value;
    const author = document.getElementById('author').value;
    const publishedDate = document.getElementById('publishedDate').value;
    const coverImage = document.getElementById('coverImage').files[0];
    console.log(title + " "+ author + " "+ publishedDate +" "+ coverImage);

    const book = {
        title: title,
        author: author,
        publishedDate: publishedDate
    };

    await addBook(book, coverImage);
});

// Function to fetch books from the API
function fetchBooks() {
    fetch(API_URL)
        .then(response => {
            if (!response.ok) throw new Error('Failed to fetch books');
            return response.json();
        })
        .then(books => {
            const bookList = document.getElementById('bookList');
            bookList.innerHTML = '';
            books.forEach(book => {
                const li = document.createElement('li');
                li.textContent = `${book.title} by ${book.author} (Published: ${book.publishedDate})`;
                if (book.coverImageUrl) {
                    const img = document.createElement('img');
                    img.src = book.coverImageUrl;
                    img.alt = `${book.title} cover`;
                    img.style.maxWidth = '100px';
                    li.appendChild(img);
                }
                bookList.appendChild(li);
            });
        })
        .catch(error => console.error('Error fetching books:', error));
}

// Function to add a new book with optional cover image
async function addBook(book, coverImage) {
    const formData = new FormData();
    formData.append('book', new Blob([JSON.stringify(book)], { type: 'application/json' }));
    if (coverImage) {
        formData.append('coverImage', coverImage);
    }

    try {
        const response = await fetch(API_URL, {
            method: 'POST',
            body: formData
        });

        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`Failed to add book: ${errorText}`);
        }

        await response.json();
        fetchBooks(); // Refresh the list
        document.getElementById('bookForm').reset(); // Clear the form
    } catch (error) {
        console.error('Error adding book:', error);
    }
}