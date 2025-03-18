package com.bookverse.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.bookverse.model.Book;

public interface BookRepository extends JpaRepository<Book, Long> {
}
