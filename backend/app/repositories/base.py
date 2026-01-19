"""
Base repository interface.

Provides common CRUD operations for all repositories.
"""
from abc import ABC, abstractmethod
from typing import Generic, List, Optional, TypeVar

from pydantic import BaseModel

# Type variables for generic repository
ModelType = TypeVar("ModelType")
CreateSchemaType = TypeVar("CreateSchemaType", bound=BaseModel)
UpdateSchemaType = TypeVar("UpdateSchemaType", bound=BaseModel)


class BaseRepository(ABC, Generic[ModelType, CreateSchemaType, UpdateSchemaType]):
    """Abstract base repository with common CRUD operations."""

    @abstractmethod
    async def get(self, id: str) -> Optional[ModelType]:
        """Get a single record by ID."""
        pass

    @abstractmethod
    async def get_multi(
        self,
        skip: int = 0,
        limit: int = 100,
    ) -> List[ModelType]:
        """Get multiple records with pagination."""
        pass

    @abstractmethod
    async def create(self, obj_in: CreateSchemaType) -> ModelType:
        """Create a new record."""
        pass

    @abstractmethod
    async def update(
        self,
        id: str,
        obj_in: UpdateSchemaType,
    ) -> Optional[ModelType]:
        """Update an existing record."""
        pass

    @abstractmethod
    async def delete(self, id: str) -> bool:
        """Delete a record by ID."""
        pass

    @abstractmethod
    async def exists(self, id: str) -> bool:
        """Check if a record exists."""
        pass
