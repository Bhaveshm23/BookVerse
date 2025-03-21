package com.bookverse.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import java.io.IOException;

@Service
@RequiredArgsConstructor
@Slf4j

public class S3Service {
    private final S3Client s3Client;
    private  final String bookCoverBucketName = "bookverse-cover-images";


    public String uploadCoverImage(MultipartFile file, String bookId) throws IOException {
        String key = "covers/"+bookId+"/"+file.getOriginalFilename();
        PutObjectRequest putObjectRequest = PutObjectRequest.builder()
                .bucket(bookCoverBucketName)
                .key(key)
                .build();
        log.info("Uploading to S3: bucket={}, key={}", bookCoverBucketName, key);

        try {
            s3Client.putObject(putObjectRequest, RequestBody.fromInputStream(file.getInputStream(), file.getSize()));
            log.info("Upload successful");
        } catch (Exception e) {
            log.error("S3 upload failed", e);
            throw e;
        }

        return s3Client.utilities().getUrl(builder -> builder.bucket(bookCoverBucketName).key(key)).toString();
    }
}
