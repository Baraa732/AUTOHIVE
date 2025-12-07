<?php

namespace App\Exceptions;

use Exception;

class AdminException extends Exception
{
    protected $statusCode;

    public function __construct($message = 'Admin operation failed', $statusCode = 400, Exception $previous = null)
    {
        $this->statusCode = $statusCode;
        parent::__construct($message, 0, $previous);
    }

    public function getStatusCode()
    {
        return $this->statusCode;
    }

    public function render($request)
    {
        if ($request->expectsJson()) {
            return response()->json([
                'success' => false,
                'message' => $this->getMessage(),
            ], $this->statusCode);
        }

        return back()->withErrors(['error' => $this->getMessage()]);
    }
}