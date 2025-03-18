package com.bookverse.controller;

import com.bookverse.model.Book;
import com.bookverse.service.BookService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/books")
@RequiredArgsConstructor
public class BookController {

    private final BookService bookService;

    @GetMapping
    public List<Book> getAllBooks(){
        return bookService.getAllBooks();
    }

    @PostMapping
    public Book addBook(@RequestBody Book book){
        return bookService.addBook(book);
    }
}
