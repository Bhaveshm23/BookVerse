package com.bookverse.service;


import com.bookverse.model.Book;
import com.bookverse.repository.BookRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@Service
@RequiredArgsConstructor
public class BookService {
    private final BookRepository bookRepository;
    private final S3Service s3Service;

    public List<Book> getAllBooks(){
        return bookRepository.findAll();
    }


    public Book addBook(Book book, MultipartFile coverImage) throws IOException {
        //Save the book first to generate the ID
        Book savedBook = bookRepository.save(book);

        if(coverImage!=null && !coverImage.isEmpty()){
            String imageURL = s3Service.uploadCoverImage(coverImage, savedBook.getId().toString());
            savedBook.setCoverImageUrl(imageURL);
            return bookRepository.save(book);
        }

        return savedBook;

    }
}
