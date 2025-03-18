package com.bookverse.service;


import com.bookverse.model.Book;
import com.bookverse.repository.BookRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BookService {
    private final BookRepository bookRepository;

    public List<Book> getAllBooks(){
        return bookRepository.findAll();
    }


    public Book addBook(Book book){
        return bookRepository.save(book);
    }
}
