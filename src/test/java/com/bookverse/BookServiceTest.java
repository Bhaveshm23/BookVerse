package com.bookverse;

import com.bookverse.model.Book;
import com.bookverse.repository.BookRepository;
import com.bookverse.service.BookService;
import com.bookverse.service.S3Service;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockMultipartFile;

import java.io.IOException;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.*;


public class BookServiceTest {

    private BookRepository bookRepository;
    private S3Service s3Service;
    private BookService bookService;
    @BeforeEach
    void setup(){
        bookRepository = mock(BookRepository.class);
        s3Service = mock(S3Service.class);
        bookService = new BookService(bookRepository, s3Service);

    }

    @Test
    public void addBook_withoutCoverImage_savesBook() throws IOException{
        Book book = new Book();
        book.setTitle("Test book title");

        //Mocking save to get id
        Book savedBook = new Book();
        savedBook.setTitle("Test book title");
        savedBook.setId(1L);


        when(bookRepository.save(any(Book.class))).thenReturn(savedBook);

        Book result = bookService.addBook(book,null);
        assertEquals(savedBook.getId(), result.getId());
        verify(bookRepository, times(1)).save(any(Book.class)); //book repository is called once
        verify(s3Service, never()).uploadCoverImage(any(), any()); //s3 is never called

    }

    @Test

    public void addBook_withCoverImage_savesBookTwiceWithUrl() throws IOException{

        Book book = new Book();
        book.setTitle("Test book title");

        //Mocking save to get id
        Book savedBook = new Book();
        savedBook.setTitle("Test book title");
        savedBook.setId(1L);


        when(bookRepository.save(any(Book.class))).thenReturn(savedBook);

        MockMultipartFile coverImage = new MockMultipartFile(
                "coverImage",
                "cover.jpg",
                "image/jpeg",
                "test-content".getBytes()
        );

        String mockUrl = "https://s3.amazonaws.com/bookverse/covers/1/cover.jpg";
        when(s3Service.uploadCoverImage(coverImage, "1")).thenReturn(mockUrl);

        Book result = bookService.addBook(book, coverImage);

        assertEquals(mockUrl, result.getCoverImageUrl());
        verify(bookRepository,times(2)).save(any(Book.class));
        verify(s3Service, times(1)).uploadCoverImage(coverImage, "1");

    }


    @Test
    void addBook_s3UploadFails_throwsIOException() throws IOException {
        Book book = new Book();
        book.setTitle("Failing upload Book");

        Book savedBook = new Book();
        savedBook.setId(2L);

        when(bookRepository.save(any(Book.class))).thenReturn(savedBook);

        MockMultipartFile coverImage = new MockMultipartFile(
                "coverImage",
                "cover.jpg",
                "image/jpeg",
                "fake-image".getBytes()
        );

        when(s3Service.uploadCoverImage(any(), any()))
                .thenThrow(new IOException("S3 failed"));

        assertThrows(IOException.class, () -> bookService.addBook(book, coverImage));
    }

}

