package com.bookverse.controller;

import com.bookverse.model.Book;
import com.bookverse.service.BookService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/books")
@RequiredArgsConstructor
public class BookController {

    private final BookService bookService;

    //Get all books
    @GetMapping
    public List<Book> getAllBooks(){
        return bookService.getAllBooks();
    }

    //Add a book
    @PostMapping(consumes = {"multipart/form-data"})
    public Book addBook(@RequestPart("book") Book book,@RequestPart(value = "coverImage", required = false) MultipartFile coverImage) throws IOException {
        return bookService.addBook(book, coverImage);
    }

}
