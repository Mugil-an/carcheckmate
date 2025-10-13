// lib/core/exceptions/ocr_exceptions.dart
// OCR and document processing specific exceptions

/// Base class for all OCR exceptions
abstract class OCRException implements Exception {
  final String message;
  final String? errorCode;
  
  const OCRException(this.message, {this.errorCode});
  
  @override
  String toString() => message;
}

/// Document processing exceptions
class DocumentProcessingException extends OCRException {
  const DocumentProcessingException({String? errorCode}) 
      : super('Failed to process document. Please try with a clearer image.', errorCode: errorCode);
}

class DocumentFormatException extends OCRException {
  const DocumentFormatException({String? errorCode}) 
      : super('Unsupported document format. Please use PDF, JPG, or PNG files.', errorCode: errorCode);
}

class DocumentSizeException extends OCRException {
  const DocumentSizeException({String? errorCode}) 
      : super('Document size too large. Please use files smaller than 10MB.', errorCode: errorCode);
}

class DocumentQualityException extends OCRException {
  const DocumentQualityException({String? errorCode}) 
      : super('Document quality too poor for processing. Please use a clearer image.', errorCode: errorCode);
}

/// Image processing exceptions
class ImageProcessingException extends OCRException {
  const ImageProcessingException({String? errorCode}) 
      : super('Failed to process image. Please try with a different image.', errorCode: errorCode);
}

class ImageTooBlurryException extends OCRException {
  const ImageTooBlurryException({String? errorCode}) 
      : super('Image is too blurry for text recognition. Please take a clearer photo.', errorCode: errorCode);
}

class ImageTooSmallException extends OCRException {
  const ImageTooSmallException({String? errorCode}) 
      : super('Image resolution too low. Please use a higher resolution image.', errorCode: errorCode);
}

class ImageCorruptedException extends OCRException {
  const ImageCorruptedException({String? errorCode}) 
      : super('Image file is corrupted. Please try with a different image.', errorCode: errorCode);
}

/// PDF processing exceptions
class PDFProcessingException extends OCRException {
  const PDFProcessingException({String? errorCode}) 
      : super('Failed to process PDF document. Please try again.', errorCode: errorCode);
}

class PDFPasswordProtectedException extends OCRException {
  const PDFPasswordProtectedException({String? errorCode}) 
      : super('PDF is password protected. Please remove password and try again.', errorCode: errorCode);
}

class PDFCorruptedException extends OCRException {
  const PDFCorruptedException({String? errorCode}) 
      : super('PDF file is corrupted. Please try with a different file.', errorCode: errorCode);
}

class PDFTooManyPagesException extends OCRException {
  const PDFTooManyPagesException({String? errorCode}) 
      : super('PDF has too many pages. Please use files with maximum 20 pages.', errorCode: errorCode);
}

/// OCR service exceptions
class OCRServiceUnavailableException extends OCRException {
  const OCRServiceUnavailableException({String? errorCode}) 
      : super('OCR service is currently unavailable. Please try again later.', errorCode: errorCode);
}

class OCRAPIException extends OCRException {
  const OCRAPIException({String? errorCode}) 
      : super('OCR processing failed. Please try again.', errorCode: errorCode);
}

class OCRTimeoutException extends OCRException {
  const OCRTimeoutException({String? errorCode}) 
      : super('OCR processing timed out. Please try with a smaller file.', errorCode: errorCode);
}

class OCRRateLimitException extends OCRException {
  const OCRRateLimitException({String? errorCode}) 
      : super('OCR rate limit exceeded. Please try again after some time.', errorCode: errorCode);
}

/// Text recognition exceptions
class TextRecognitionFailedException extends OCRException {
  const TextRecognitionFailedException({String? errorCode}) 
      : super('Failed to recognize text in document. Please try with a clearer image.', errorCode: errorCode);
}

class NoTextFoundException extends OCRException {
  const NoTextFoundException({String? errorCode}) 
      : super('No readable text found in the document. Please check your file.', errorCode: errorCode);
}

class InsufficientTextException extends OCRException {
  const InsufficientTextException({String? errorCode}) 
      : super('Insufficient text found for processing. Please use a document with more content.', errorCode: errorCode);
}

/// Service record analysis exceptions
class ServiceRecordAnalysisException extends OCRException {
  const ServiceRecordAnalysisException({String? errorCode}) 
      : super('Failed to analyze service records. Please try again.', errorCode: errorCode);
}

class ServiceRecordFormatException extends OCRException {
  const ServiceRecordFormatException({String? errorCode}) 
      : super('Service record format not recognized. Please use standard service invoices.', errorCode: errorCode);
}

class ServiceRecordDataException extends OCRException {
  const ServiceRecordDataException({String? errorCode}) 
      : super('Failed to extract service record data. Please ensure document contains service details.', errorCode: errorCode);
}

/// Camera and file picker exceptions
class CameraPermissionException extends OCRException {
  const CameraPermissionException({String? errorCode}) 
      : super('Camera permission denied. Please enable camera access in settings.', errorCode: errorCode);
}

class CameraUnavailableException extends OCRException {
  const CameraUnavailableException({String? errorCode}) 
      : super('Camera is not available on this device.', errorCode: errorCode);
}

class FilePickerException extends OCRException {
  const FilePickerException({String? errorCode}) 
      : super('Failed to select file. Please try again.', errorCode: errorCode);
}

class StoragePermissionException extends OCRException {
  const StoragePermissionException({String? errorCode}) 
      : super('Storage permission denied. Please enable storage access in settings.', errorCode: errorCode);
}

/// Network related OCR exceptions
class OCRNetworkException extends OCRException {
  const OCRNetworkException({String? errorCode}) 
      : super('Network error during OCR processing. Please check your connection.', errorCode: errorCode);
}

/// Generic OCR exception
class GenericOCRException extends OCRException {
  const GenericOCRException([String? customMessage, String? errorCode]) 
      : super(customMessage ?? 'An OCR processing error occurred. Please try again.', errorCode: errorCode);
}

/// Upload exceptions
class DocumentUploadException extends OCRException {
  const DocumentUploadException({String? errorCode}) 
      : super('Failed to upload document. Please check your connection and try again.', errorCode: errorCode);
}

class DocumentUploadTimeoutException extends OCRException {
  const DocumentUploadTimeoutException({String? errorCode}) 
      : super('Document upload timed out. Please try with a smaller file.', errorCode: errorCode);
}