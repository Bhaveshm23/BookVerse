package com.bookverse.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import java.io.IOException;

@Service
@RequiredArgsConstructor

public class S3Service {
    private final S3Client s3Client;
    private  final String bookCoverBucketName = "bookverse-cover-images";


    public String uploadCoverImage(MultipartFile file, String bookId) throws IOException {
        String key = "covers/"+bookId+"/"+file.getOriginalFilename();
        PutObjectRequest putObjectRequest = PutObjectRequest.builder()
                .bucket(bookCoverBucketName)
                .key(key)
                .acl("public-read")
                .build();

        s3Client.putObject(putObjectRequest, RequestBody.fromInputStream(file.getInputStream(), file.getSize()));

        return s3Client.utilities().getUrl(builder -> builder.bucket(bookCoverBucketName).key(key)).toString();
    }
}
